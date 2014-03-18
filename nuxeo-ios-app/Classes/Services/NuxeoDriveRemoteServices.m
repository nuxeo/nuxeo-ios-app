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

#import "NuxeoRetrieveException.h"

@implementation NuxeoDriveRemoteServices

+ (NuxeoDriveRemoteServices *) instance
{
    static dispatch_once_t pred = 0;
    __strong static NuxeoDriveRemoteServices * _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        // or some other init method
    });
    return _sharedObject;
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


// Setup allHierarchy
- (void) setupAllHierarchy:(NuxeoDriveServicesBlock)completion
{
    NUXHierarchy * allHierarchy = [NUXHierarchy hierarchyWithName:[self mainHierarchyName]];
    
    [allHierarchy setCompletionBlock:^{
        NSLog(@"hierarchy done !");
        completion(allHierarchy);
    }];
    
    allHierarchy.nodeBlock = ^NSArray *(NUXEntity *entity, NSUInteger depth)
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
            
            if ([nuxSubRequest responseData] != nil) {
                NUXDocuments * documents = [nuxSubRequest responseEntityWithError:nil];
                return documents.entries;//liste des documents
            }
        }
        return nil;
    };
}

// Retrieve Hierarchy for suite
- (void) retrieveSuiteHierarchyWithName:(NSString *)iName rootPath:(NSString *)iPath completionBlock:(NuxeoDriveServicesBlock)completion
{
    NSString * hierarchieName = [NSString stringWithFormat:@"%@", iName];
    NUXHierarchy * suiteHierarchy = [NUXHierarchy hierarchyWithName:hierarchieName];
    
    if ([APP_DELEGATE isNetworkConnected] == YES)
    {
        [suiteHierarchy resetCache];
    }
    // Create the background queue
    dispatch_queue_t backgroundQueue = dispatch_queue_create([NSString stringWithFormat:@"%@%@",@"Hierarchy", iName].UTF8String, NULL);
    
    dispatch_async(backgroundQueue, ^{
        
        NUXSession * nuxSession = [NUXSession sharedSession];
        // Request by path
        NSString * requestFormat = @"SELECT * FROM Folder where ecm:path startswith '%@' and ecm:currentLifeCycleState <> 'deleted'";
        NSString * query = [NSString stringWithFormat:requestFormat, iPath];
        NUXRequest * nuxRequest = [nuxSession requestQuery:query];
        
        [suiteHierarchy setCompletionBlock:^{
            NuxeoLogD(@"hierarchy done !");
            if (completion != nil)
            {
                completion(suiteHierarchy);
            }
        }];
        
        suiteHierarchy.nodeBlock = ^NSArray *(NUXEntity *entity, NSUInteger depth)
        {
            NUXDocument *doc = (NUXDocument *)entity;
            {
                // retrieve all documents in this node in synchronize mode
                NSString * subRequestFormat = @"SELECT * FROM Document where ecm:path startswith '%@' and ecm:currentLifeCycleState <> 'deleted'";
                NSString * subRequestQuery = [NSString stringWithFormat:subRequestFormat, doc.path];
                
                NUXRequest * nuxSubRequest = [nuxSession requestQuery:subRequestQuery];
                
                [nuxSubRequest startSynchronous];
                if ([nuxSubRequest responseData] != nil)
                {
                    NUXDocuments * documents = [nuxSubRequest responseEntityWithError:nil];
                    return documents.entries;//liste des documents
                }
                
            }
            return nil;
        };
        
        [suiteHierarchy loadWithRequest:nuxRequest];
        [suiteHierarchy waitUntilLoadingIsDone];
        
    });
                   
    // won't be actually released until queue is empty
    dispatch_release(backgroundQueue);
    

}

- (BOOL) shouldLoadDocumentsForNode:(NUXDocument *)nuxDocument withDepth:(int)iDepth
{
    return YES;
}


- (NSString *) mainHierarchyName
{
    return [NSString stringWithFormat:@"%@", kNuxeoHierarchyAllProducts];
}

- (void) retrieveBrowseAllHierarchy:(NuxeoDriveServicesBlock)completion;
{
    NUXHierarchy * allHierarchy = [NUXHierarchy hierarchyWithName:[self mainHierarchyName]];
    
    if ([APP_DELEGATE isNetworkConnected] == YES)
    {
        [allHierarchy resetCache];
        
        // Create the background queue
        dispatch_queue_t backgroundQueue = dispatch_queue_create([self mainHierarchyName].UTF8String, NULL);
        
        dispatch_async(backgroundQueue, ^{
            NUXSession * nuxSession = [NUXSession sharedSession];
            // Request by path
            NSString * requestFormat = @"SELECT * FROM Folder where ecm:path startswith '%@' and ecm:currentLifeCycleState <> 'deleted'";
            NSString * query = [NSString stringWithFormat:requestFormat, kNuxeoPathInitial];
            NUXRequest * nuxRequest = [nuxSession requestQuery:query];
            [nuxRequest addParameterValue:@"100" forKey:@"pageSize"];
            
            [allHierarchy loadWithRequest:nuxRequest];
        });
        
        // won't be actually released until queue is empty
        dispatch_release(backgroundQueue);
    }
    else
    {
        completion(allHierarchy);
    }

}

- (NSArray *) retrieveAllDocumentsFromMainHierarchy
{
    // Retrieve all documents
    NSString * hierarchyName = [[NuxeoDriveRemoteServices instance] mainHierarchyName];
    NUXHierarchy * currentHierarchy = [NUXHierarchy hierarchyWithName:hierarchyName];
    NSArray * allDocs = [currentHierarchy contentOfAllDocuments];
    
    NSMutableDictionary* sortedDocs = [NSMutableDictionary dictionary];
    for (NUXDocument * doc in allDocs)
    {
        [sortedDocs setObject:doc forKey:doc.uid];
    }
    
    return [sortedDocs allValues];
}




@end








