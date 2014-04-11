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

#define kNuxeoSynchroPointNameIndex         0
#define kNuxeoSynchroPointStatusIndex       1
#define kNuxeoSynchroPointDocumentIndex     2


@implementation NuxeoDriveRemoteServices

@synthesize synchronisedPoints;

- (void) setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAddSyncPoint:) name:NOTIF_ADD_SYNC_POINT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoveSyncPoint:) name:NOTIF_REMOVE_SYNC_POINT object:nil];
    
    // Load synchronised points save in app
    synchronisedPoints = [[[[NuxeoSettingsManager instance] readSetting:USER_SYNC_POINTS_LIST defaultValue:[NSMutableDictionary dictionary]] mutableCopy] retain];
    
    // All notifications sended during synchronization process of hierrchies
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHierarchyTreeComplete:) name:NOTIF_HIERARCHY_FOLDER_TREE_DOWNLOADED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHierarchyContentComplete:) name:NOTIF_HIERARCHY_BINARY_DOWNLOADED object:nil];
    
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

- (void) onHierarchyTreeComplete:(NSNotification *)notification
{
    NSString * hierarchyName = (NSString *) notification.object;
    [((NSMutableArray *)[synchronisedPoints objectForKey:hierarchyName]) replaceObjectAtIndex:kNuxeoSynchroPointStatusIndex withObject:[NSNumber numberWithInt:NuxeoHierarchieStatusTreeLoaded]];
    [[NuxeoSettingsManager instance] saveSetting:synchronisedPoints forKey:USER_SYNC_POINTS_LIST];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REFRESH_UI object:hierarchyName];
}

- (void) onHierarchyContentComplete:(NSNotification *)notification
{
    NSString * hierarchyName = (NSString *) notification.object;
    [((NSMutableArray *)[synchronisedPoints objectForKey:hierarchyName]) replaceObjectAtIndex:kNuxeoSynchroPointStatusIndex withObject:[NSNumber numberWithInt:NuxeoHierarchieStatusContentLoaded]];
    [[NuxeoSettingsManager instance] saveSetting:synchronisedPoints forKey:USER_SYNC_POINTS_LIST];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REFRESH_UI object:hierarchyName];
}

- (void) onAddSyncPoint:(NSNotification *)notification
{
    __block NSString * hierarchyName = (NSString *) notification.object;
    
    [self loadFullHierarchyByName:hierarchyName];
    
}

- (void) onRemoveSyncPoint:(NSNotification *)notification
{
    NSString * hierarchyName = (NSString *) notification.object;
    NUXHierarchy * aHierarchy = [NUXHierarchy hierarchyWithName:hierarchyName];
    [aHierarchy resetCache];
    
    [synchronisedPoints removeObjectForKey:hierarchyName];
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
                
//                // retrieve all documents in this node in synchronize mode
//                NSString * subRequestFormat = @"SELECT * FROM Document where ecm:path startswith '%@' and ecm:currentLifeCycleState <> 'deleted'";
//                NSString * subRequestQuery = [NSString stringWithFormat:subRequestFormat, doc.path];
//                
//                NUXRequest * nuxSubRequest = [nuxSession requestQuery:subRequestQuery];
//                [nuxSubRequest startSynchronous];
//                
//                // XXX Sleep to ensure that other threads finish to filled nuxSubRequest's response fields.
//                [NSThread sleepForTimeInterval:0.002f];
//                
                
                NUXRequest * nuxSubRequest = [nuxSession requestChildren:doc.uid];
                [nuxSubRequest startSynchronous];
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
    
    if (aHierarchy.failureBlock == nil)
    {
        [aHierarchy setFailureBlock:^{
            if (completion != nil)
            {
                completion(aHierarchy);
            }
        }];
    }
    
    return aHierarchy;
}


- (void) loadHierarchy:(NSString *)iHerarchieName completionBlock:(NuxeoDriveServicesBlock)completion
{
    __block NUXHierarchy * aHierarchy = [self setupHierarchy:iHerarchieName completionBlock:completion];
    
    if ([APP_DELEGATE isNetworkConnected] == YES)
    {
        [aHierarchy resetCache];
        
        // Create the background queue
        dispatch_queue_t backgroundQueue = dispatch_queue_create(iHerarchieName.UTF8String, NULL);
        
        dispatch_async(backgroundQueue, ^{
            NUXSession * nuxSession = [NUXSession sharedSession];
            // Request by path
            //NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'Folderish'"];
//            NSString * requestFormat = @"SELECT * FROM Document where ecm:path startswith '%@' and ecm:mixinType = 'Folderish'";
            //NSString * requestFormat = @"SELECT * FROM Document where ecm:path startswith '%@'";
            
            NSString * requestFormat = @"SELECT * FROM Document where ecm:mixinType = 'Folderish' and (ecm:path = '%@' or ecm:path startswith '%@')";
            
            NSString * query = [NSString stringWithFormat:requestFormat, iHerarchieName, iHerarchieName];
            NUXRequest * nuxRequest = [nuxSession requestQuery:query];
//            [nuxRequest addParameterValue:@"1000" forKey:@"pageSize"];
            
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

- (void)loadFullHierarchyByName:(NSString *)hierarchyName
{
    NUXRequest * docRequest = [[NUXSession sharedSession] requestDocument:hierarchyName];
    [docRequest setCompletionBlock:^(NUXRequest *request)
    {
        // first element = hierarchie name
        // second element : indicate hierarchie's status
        // third element : the NUXDocument
        [self.synchronisedPoints setObject:[NSMutableArray arrayWithObjects:hierarchyName, [NSNumber numberWithInt:NuxeoHierarchieStatusNotLoaded], [request responseData], nil] forKey:hierarchyName];
        [[NuxeoSettingsManager instance] saveSetting:synchronisedPoints forKey:USER_SYNC_POINTS_LIST];
    }];
    [docRequest startSynchronous];
    
    [self loadHierarchy:hierarchyName completionBlock:^(id hierarchy)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HIERARCHY_FOLDER_TREE_DOWNLOADED object:hierarchyName];
         
         // TODO asynchronize this work
         [self loadBinariesOfHierarchy:hierarchyName completionBlock:^(id hierarchyName)
          {
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_HIERARCHY_ALL_DOWNLOADED object:hierarchyName];
          }];
         
     }];


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
        return [[((NSArray *)[synchronisedPoints objectForKey:hierarchieName]) objectAtIndex:kNuxeoSynchroPointStatusIndex] intValue];
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
        NUXDocuments * result = [[NUXDocuments alloc] init];
        NSMutableArray * listOfRoots = [NSMutableArray array];
        for (NSArray * synchronizePoint in synchPoints)
        {
//            NUXHierarchy * hierarchy = [self getHierarchyWithName:[synchronizePoint objectAtIndex:kNuxeoSynchroPointNameIndex]];
            NSError * error = nil;
            NUXDocument * rootHierarchy = [NUXJSONSerializer entityWithData:[synchronizePoint objectAtIndex:kNuxeoSynchroPointDocumentIndex] error:&error] ;
            if (rootHierarchy == nil)
            {
                rootHierarchy = [[NUXDocument alloc] initWithEntityType:@"NUXDocument"];
            }
            [listOfRoots addObject:rootHierarchy];
        }
        result.entries = listOfRoots;
        
        completion(result);
    }
    else
    {
        NUXSession * nuxSession = [NUXSession sharedSession];
        NUXRequest * nuxRequest = [nuxSession requestOperation:@"NuxeoDrive.GetRoots"];
        [nuxRequest startWithCompletionBlock:^(NUXRequest *request) {
            // result
            NSError * error = nil;
            NUXDocuments * listOfSynchroPoints = [NUXJSONSerializer entityWithData:[request responseData] error:&error];
            
            // Add missing synchronized points
            for (NUXDocument * serverSyncPoint in listOfSynchroPoints.entries)
            {
                if ([[self.synchronisedPoints allKeys] containsObject:serverSyncPoint.path] == NO)
                {
                    [self.synchronisedPoints setObject:[NSMutableArray arrayWithObjects:serverSyncPoint.path, [NSNumber numberWithInt:NuxeoHierarchieStatusNotLoaded], serverSyncPoint, nil] forKey:serverSyncPoint.path];
                }
            }
            // Remove old synchronized points
            for (NSString * synchronizedPointPath in [self.synchronisedPoints allKeys])
            {
                BOOL containSynchroPoint = NO;
                for (NUXDocument * serverSyncPoint in listOfSynchroPoints.entries)
                {
                    if ([serverSyncPoint.path isEqualToString:synchronizedPointPath])
                    {
                        containSynchroPoint = YES;
                        break;
                    }
                }
                if (containSynchroPoint == NO)
                {
                    [self.synchronisedPoints removeObjectForKey:synchronizedPointPath];
                    NUXHierarchy * aHierarchy = [NUXHierarchy hierarchyWithName:synchronizedPointPath];
                    [aHierarchy resetCache];
                }
            }
            
            completion(listOfSynchroPoints);
            
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

- (void) refreshAllSyncPoints:(BOOL)withContent
{
    if ([APP_DELEGATE isNetworkConnected] == YES)
    {
        APP_DELEGATE.synchronizationInProgress = YES;
        [[NuxeoSettingsManager instance] saveBoolSetting:APP_DELEGATE.synchronizationInProgress forKey:SYNCHRONISATION_IN_PROGRESS];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SYNC_ALL_BEGIN object:nil];
        
        [self retrieveAllSynchronizePoints:^(id documents)
        {
            if (withContent == YES && [self downloadIsPossible] == YES)
            {
                __block int countOfDownloadedHierarchy = 0;
                [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_HIERARCHY_ALL_DOWNLOADED object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note)
                {
                    // Count the download hierarchy
                    countOfDownloadedHierarchy++;
                    if (countOfDownloadedHierarchy >= [[self.synchronisedPoints allKeys] count])
                    {
                        [self endAllSyncPointsRefreshProcess];
                    }
                }];
                
                if ([[self.synchronisedPoints allKeys] count] > 0)
                {
                    for (NSArray * synchroPointInfos in [self.synchronisedPoints allValues])
                    {
                        NSString * hierarchyName = [synchroPointInfos objectAtIndex:kNuxeoSynchroPointNameIndex];
                        
                        [self loadFullHierarchyByName:hierarchyName];
                    }
                }
                else
                {
                    [self endAllSyncPointsRefreshProcess];
                }
            }
        }];
    }
    else
    {
        [self endAllSyncPointsRefreshProcess];
    }
}

- (void) endAllSyncPointsRefreshProcess
{
    APP_DELEGATE.synchronizationInProgress = NO;
    [[NuxeoSettingsManager instance] saveBoolSetting:APP_DELEGATE.synchronizationInProgress forKey:SYNCHRONISATION_IN_PROGRESS];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SYNC_ALL_FINISH object:nil];

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

- (BOOL) downloadIsPossible
{
    if (APP_DELEGATE.isNetworkConnected == YES)
    {
        if (APP_DELEGATE.isWifiConnected == YES)
        {
            return YES;
        } else  if( [[NuxeoSettingsManager instance] readBoolSetting:USER_SYNC_OVER_CELLULAR defaulValue:NO] == YES && APP_DELEGATE.isWifiConnected == NO)
        {
            return YES;
        }
    }
    return NO;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [synchronisedPoints release];
    
    [super dealloc];
    
}

@end








