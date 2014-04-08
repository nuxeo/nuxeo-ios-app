//
//  ￼NuxeoDriveRemoteServices.m
//  NuxeoDrive
//
/* (C) Copyright 2013-2014 Nuxeo SA (http://nuxeo.com/) and contributors.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl-2.1.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * Contributors:
 * 	Matthias Rouberol
 */

#import "NuxeoDriveRemoteServices.h"

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXSession+requests.h>
#import <NuxeoSDK/NUXDocument.h>
#import <NuxeoSDK/NUXDocuments.h>
#import <NuxeoSDK/NUXHierarchy.h>
#import <NuxeoSDK/NUXHierarchyDB.h>
#import <NuxeoSDK/NUXJSONSerializer.h>
#import <NuxeoSDK/NUXBlobStore.h>

#import "NuxeoSettingsManager.h"

#import "NuxeoRetrieveException.h"

#define kNuxeoHierarchyStatusIndex      1


@implementation NuxeoDriveRemoteServices

@synthesize synchronisedPoints;

- (void) setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAddSyncPoint:) name:NOTIF_ADD_SYNC_POINT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoveSyncPoint:) name:NOTIF_REMOVE_SYNC_POINT object:nil];
    
    // Load synchronised points save in app
    synchronisedPoints = [[[NuxeoSettingsManager instance] readSetting:USER_SYNC_POINTS_LIST defaultValue:[NSMutableDictionary dictionary]] retain];
}

+ (NuxeoDriveRemoteServices *) instance
{
    static dispatch_once_t pred = 0;
    __strong static NuxeoDriveRemoteServices * _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        // or some other init method
        [_sharedObject setup];
    });
    return _sharedObject;
}

#pragma mark Notification selectors
- (void) onAddSyncPoint:(NSNotification *)notification
{
    __block NSString * hierarchieName = (NSString *) notification.object;
    
    // first element = hierarchie name
    // second element : indicate hierarchie's status
    [synchronisedPoints setObject:[NSMutableArray arrayWithObjects:hierarchieName, [NSNumber numberWithInt:NuxeoHierarchieStatusNotLoaded], nil] forKey:hierarchieName];
    [[NuxeoSettingsManager instance] saveSetting:synchronisedPoints forKey:USER_SYNC_POINTS_LIST];
    
    [self loadHierarchy:hierarchieName completionBlock:^(id hierarchy)
    {
        [((NSMutableArray *)[synchronisedPoints objectForKey:hierarchieName]) replaceObjectAtIndex:kNuxeoHierarchyStatusIndex withObject:[NSNumber numberWithInt:NuxeoHierarchieStatusLoaded]];
        [[NuxeoSettingsManager instance] saveSetting:synchronisedPoints forKey:USER_SYNC_POINTS_LIST];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HIERARCHY_FOLDER_TREE_DOWNLOADED object:hierarchieName];
        
        // TODO asynchronize this work
        [self loadBinariesOfHierarchy:hierarchieName completionBlock:^(id hierarchyName)
        {
            [((NSMutableArray *)[synchronisedPoints objectForKey:hierarchieName]) replaceObjectAtIndex:kNuxeoHierarchyStatusIndex withObject:[NSNumber numberWithInt:NuxeoHierarchieStatusBinariesLoaded]];
            [[NuxeoSettingsManager instance] saveSetting:synchronisedPoints forKey:USER_SYNC_POINTS_LIST];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HIERARCHY_ALL_DOWNLOADED object:hierarchieName];
        }];
        
    }];
}

- (void) onRemoveSyncPoint:(NSNotification *)notification
{
    NSString * hierarchieName = (NSString *) notification.object;
    NUXHierarchy * aHierarchy = [NUXHierarchy hierarchyWithName:hierarchieName];
    [aHierarchy resetCache];
    
    [synchronisedPoints removeObjectForKey:hierarchieName];
}

#pragma mark -
#pragma mark Overriding Master Methods
#pragma mark -

- (NSString *) getIOSLanguage
{
    NSString * country = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    NSString * lang = [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode];
    
    /* Possibles values
     en-us
     en-uk
     fr-fr
     de-de
     it-it
     ru
     es-es
     */
    return [NSString stringWithFormat:@"%@-%@", lang, country];
}


// ===========================================================================================

// Indicate if documents for a node of a the hierarchy have to be loaded
- (BOOL) shouldLoadDocumentsForNode:(NUXDocument *)nuxDocument withDepth:(int)iDepth
{
    return YES;
}

#pragma mark
#pragma mark Hierarchies methods selectors
#pragma mark

// Setup a hierarchy with its name
- (NUXHierarchy *) setupHierarchy:(NSString *)iHerarchieName completionBlock:(NuxeoDriveServicesBlock)completion
{
    NUXHierarchy * aHierarchy = [NUXHierarchy hierarchyWithName:iHerarchieName];
    
    if (aHierarchy.completionBlock == nil)
    {
        [aHierarchy setCompletionBlock:^{
            NSLog(@"hierarchy done !");
            if (completion != nil)
            {
                completion(aHierarchy);
            }
        }];
    }
    
    if (aHierarchy.nodeBlock == nil)
    {
        aHierarchy.nodeBlock = ^NSArray *(NUXEntity *entity, NSUInteger depth)
        {
            NUXDocument *doc = (NUXDocument *)entity;
            if ([self shouldLoadDocumentsForNode:doc withDepth:depth] == YES)
            {
                NUXSession * nuxSession = [NUXSession sharedSession];
                
                // retrieve all documents in this node in synchronize mode
                NSString * subRequestFormat = @"SELECT * FROM Document where ecm:path startswith '%@' and ecm:currentLifeCycleState <> 'deleted'";
                NSString * subRequestQuery = [NSString stringWithFormat:subRequestFormat, doc.path];
                
                NUXRequest * nuxSubRequest = [nuxSession requestQuery:subRequestQuery];
                [nuxSubRequest startSynchronous];
                
                // XXX Sleep to ensure that other threads finish to filled nuxSubRequest's response fields.
                [NSThread sleepForTimeInterval:0.002f];
                
                if ([nuxSubRequest responseData] != nil)
                {
                    // Return subdocuments
                    NUXDocuments * documents = [nuxSubRequest responseEntityWithError:nil];
                    return documents.entries;
                }
            }
            return nil;
        };
    }
    
    return aHierarchy;
}


- (void) loadHierarchy:(NSString *)iHerarchieName completionBlock:(NuxeoDriveServicesBlock)completion
{
    __block NUXHierarchy * aHierarchy = [self setupHierarchy:iHerarchieName completionBlock:completion];//[NUXHierarchy hierarchyWithName:iHerarchieName];
    
    if ([APP_DELEGATE isNetworkConnected] == YES)
    {
        [aHierarchy resetCache];
        
        // Create the background queue
        dispatch_queue_t backgroundQueue = dispatch_queue_create(iHerarchieName.UTF8String, NULL);
        
        dispatch_async(backgroundQueue, ^{
            NUXSession * nuxSession = [NUXSession sharedSession];
            // Request by path
            NSString * requestFormat = @"SELECT * FROM Folder where ecm:path startswith '%@' and ecm:currentLifeCycleState <> 'deleted'";
            NSString * query = [NSString stringWithFormat:requestFormat, kNuxeoPathInitial];
            NUXRequest * nuxRequest = [nuxSession requestQuery:query];
            [nuxRequest addParameterValue:@"1000" forKey:@"pageSize"];
            
            [aHierarchy loadWithRequest:nuxRequest];
        });
        
        // won't be actually released until queue is empty
        dispatch_release(backgroundQueue);
    }
    else
    {
        completion(aHierarchy);
    }
    
}

- (NUXHierarchy *) getHierarchyWithName:(NSString *)iHerarchieName
{
    return [self setupHierarchy:iHerarchieName completionBlock:nil];
}


- (NSArray *) retrieveAllDocumentsOfHierarchy:(NSString *)iHierarchyName
{
    // Retrieve all documents
    NUXHierarchy * currentHierarchy = [NUXHierarchy hierarchyWithName:iHierarchyName];
    if ([currentHierarchy isLoaded] == YES)
    {
        NSArray * allDocs = [currentHierarchy contentOfAllDocuments];
        
        NSMutableDictionary* sortedDocs = [NSMutableDictionary dictionary];
        for (NUXDocument * doc in allDocs)
        {
            [sortedDocs setObject:doc forKey:doc.uid];
        }
        
        return [sortedDocs allValues];
    }
    return nil;
}

- (NuxeoHierarchieStatus) getHierarchyStatus:(NSString *)hierarchieName
{
    if ([synchronisedPoints objectForKey:hierarchieName] != nil)
    {
        return [[((NSArray *)[synchronisedPoints objectForKey:hierarchieName]) objectAtIndex:kNuxeoHierarchyStatusIndex] intValue];
    }
    return NuxeoHierarchieStatusNotLoaded;
}

// Load all binary of a hierarchy
- (void) loadBinariesOfHierarchy:(NSString *)iHerarchieName completionBlock:(NuxeoDriveServicesBlock)completion
{
    NSArray * documents = [[self retrieveAllDocumentsOfHierarchy:iHerarchieName] retain];
    NSInteger __block operations = [documents count];
    for (NUXDocument * nuxDocument in documents)
    {
        // If blobStore already has the blob, it is not necessary to redownload it.
        if ([nuxDocument hasBinaryFile] == NO)
        {
            operations -= 1;
            continue;
        }
        if ([nuxDocument hasBinaryFile] == YES)
        {
            operations -= 1;
            continue;
        }
        
        NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tempfile%d.tmp", arc4random()]];
        
        NUXSession * nuxSession = [NUXSession sharedSession];
        NUXRequest *request = [nuxSession requestDownloadBlobFrom:nuxDocument.uid
                                                       inMetadata:kXPathFileContent];
        request = [nuxSession requestDownloadBlobFrom:nuxDocument.uid inMetadata:kXPathFileContent];
        request.downloadDestinationPath = tempFile;
        request.shouldContinueWhenAppEntersBackground = YES;
        
        NUXBasicBlock syncAllDoneIfEmpty = ^(void) {
            operations -= 1;
            if (operations <= 0)
            {
                completion(iHerarchieName);
            }
        };
        
        [request setCompletionBlock:^(NUXRequest *request) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HIERARCHY_BINARY_DOWNLOADED object:nuxDocument];
            [[NUXBlobStore instance] saveBlobFromPath:tempFile withDocument:nuxDocument metadataXPath:kXPathFileContent error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
            syncAllDoneIfEmpty();
        }];
        [request setFailureBlock:^(NUXRequest *request) {
            syncAllDoneIfEmpty();
        }];
        
        [request start];
    }
    
    if (operations <= 0)
    {
        completion(iHerarchieName);
    }
    
    [documents release];
}


#pragma mark
#pragma mark Synchronized points methods
#pragma mark

// Methods for Nuxeo Drive synchronized points
- (void) retrieveAllSynchronizePoints:(NuxeoDriveServicesBlock)completion
{
    if ([APP_DELEGATE isNetworkConnected] == NO)
    {
        NSArray * synchPoints = [self.synchronisedPoints allValues];
        NSMutableArray * result = [[NSMutableArray alloc] init];
        for (NSArray * synchronizePoint in synchPoints)
        {
            NUXHierarchy * hierarchy = [self getHierarchyWithName:[synchronizePoint objectAtIndex:0]];
            [result addObject:[hierarchy nodeWithRef:[synchronizePoint objectAtIndex:0]]];
        }
        
        completion(result);
    }
    else
    {
        NUXSession * nuxSession = [NUXSession sharedSession];
        NUXRequest * nuxRequest = [nuxSession requestOperation:@"NuxeoDrive.GetRoots"];
        [nuxRequest startWithCompletionBlock:^(NUXRequest *request) {
            // result
            NSError * error = nil;
            NUXDocuments * result = [NUXJSONSerializer entityWithData:[request responseData] error:&error];
            
            completion(result);
            
        } FailureBlock:^(NUXRequest *request) {
        }];
    }
    
}

- (void) addSynchronizePoint:(NSString *)iPath completionBlock:(NuxeoDriveServicesBlock)completion
{
    NUXSession * nuxSession = [NUXSession sharedSession];
    NUXRequest * nuxRequest = [nuxSession requestOperation:@"NuxeoDrive.SetSynchronization"];
    [nuxRequest addParameterValue:@"true" forKey:@"enable"];
    ((NUXAutomationRequest *)nuxRequest).input = iPath;
    [nuxRequest startWithCompletionBlock:^(NUXRequest *request) {
        // result
        NSError * error = nil;
        NUXDocuments * result = [NUXJSONSerializer entityWithData:[request responseData] error:&error];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ADD_SYNC_POINT object:((NUXAutomationRequest *)nuxRequest).input];
        
        completion(result);
        
    } FailureBlock:^(NUXRequest *request) {
        
        
    }];
}

- (void) removeSynchronizePoint:(NSString *)iPath completionBlock:(NuxeoDriveServicesBlock)completion
{
    NUXSession * nuxSession = [NUXSession sharedSession];
    NUXRequest * nuxRequest = [nuxSession requestOperation:@"NuxeoDrive.SetSynchronization"];
    [nuxRequest addParameterValue:@"false" forKey:@"enable"];
    ((NUXAutomationRequest *)nuxRequest).input = iPath;
    [nuxRequest startWithCompletionBlock:^(NUXRequest *request) {
        // result
        NSError * error = nil;
        NUXDocuments * result = [NUXJSONSerializer entityWithData:[request responseData] error:&error];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REMOVE_SYNC_POINT object:((NUXAutomationRequest *)nuxRequest).input];
        
        completion(result);
        
    } FailureBlock:^(NUXRequest *request) {
        
        
    }];
}


- (void) refreshAllSyncPoints
{
    if ([APP_DELEGATE isNetworkConnected] == YES)
    {
        [self retrieveAllSynchronizePoints:^(id documents)
        {
            NUXDocuments * listOfSynchroPoints = (NUXDocuments *)documents;
            for (NUXDocument * synchroPoint in listOfSynchroPoints.entries)
            {
                NSString * hierarchyName = synchroPoint.path;
                [synchronisedPoints setObject:[NSMutableArray arrayWithObjects:hierarchyName, [NSNumber numberWithInt:NuxeoHierarchieStatusNotLoaded], nil] forKey:hierarchyName];
                
                [self loadHierarchy:hierarchyName completionBlock:^(id hierarchy)
                 {
                     [((NSMutableArray *)[synchronisedPoints objectForKey:hierarchyName]) replaceObjectAtIndex:kNuxeoHierarchyStatusIndex withObject:[NSNumber numberWithInt:NuxeoHierarchieStatusLoaded]];
                     
                     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HIERARCHY_FOLDER_TREE_DOWNLOADED object:hierarchyName];
                     
                     // TODO asynchronize this work
                     [self loadBinariesOfHierarchy:hierarchyName completionBlock:^(id hierarchyName)
                      {
                          [((NSMutableArray *)[synchronisedPoints objectForKey:hierarchyName]) replaceObjectAtIndex:kNuxeoHierarchyStatusIndex withObject:[NSNumber numberWithInt:NuxeoHierarchieStatusBinariesLoaded]];
                          [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HIERARCHY_ALL_DOWNLOADED object:hierarchyName];
                      }];
                     
                 }];
                
            }
        }];
    }
}


#pragma mark
#pragma mark Blob or binaries methods
#pragma mark

- (NSString *) userDocsFilePath
{
    return [[NuxeoDriveUtils applicationDocumentsPath] stringByAppendingPathComponent:@"Docs"];
}

- (NSString *) docFileName:(NSString *)name withDocId:(NSString *)docId
{
    return [NSString stringWithFormat:@"%@%@",docId, name];
}

- (NSString *) getDocPathForDocument:(NUXDocument *)nuxDocument
{
    NSString * docId = nuxDocument.uid;
    NSString * docName = [nuxDocument.properties objectForKey:@"file:filename"];
    
    return [[self userDocsFilePath] stringByAppendingPathComponent:[self docFileName:docName withDocId:docId]];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [synchronisedPoints release];
    
    [super dealloc];
    
}

@end








