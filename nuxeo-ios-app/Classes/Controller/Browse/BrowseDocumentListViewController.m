//
//  BrowseDocumentListViewController.m
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

#import "BrowseDocumentListViewController.h"

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXSession+requests.h>
#import <NuxeoSDK/NUXDocuments.h>
#import <NuxeoSDK/NUXDocument.h>
#import <NuxeoSDK/NUXBlobStore.h>
#import <NuxeoSDK/NUXHierarchy.h>
#import <NuxeoSDK/NUXJSONSerializer.h>

#import "DocumentCellView.h"

#import "NuxeoDriveRemoteServices.h"

#import "NuxeoDriveUtils.h"

#define kDocumentTableCellReuseKey      @"DocumentCell"

#define kSectionHeaderHeight    45.0

#define kFooterHeight           200.0

@implementation BrowseDocumentListViewController

#pragma mark -
#pragma mark BrowseDocumentListViewController
#pragma mark -

- (void) reloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.documentsView reloadData];
    });
    
}

- (void)updateDisplay
{
	
}

- (NUXDocument *) documentByIndexPath:(NSIndexPath *) indexPath
{
    NSArray * docs = [documents objectAtIndex:indexPath.row];
    return [docs objectAtIndex:indexPath.row];
}



#pragma mark -
#pragma mark UIViewControllerLifeCycle
#pragma mark -

/**
 * Called after the loadView call
 */
- (void)loadView
{
	[super loadView];
	
    UINib  *documentTableCellNib = [UINib nibWithNibName:kXIBDocumentTableCellView bundle:nil];
    [self.documentsView registerNib:documentTableCellNib forCellReuseIdentifier:kDocumentTableCellReuseKey];
    
}

/**
 * Called after the viewDidLoad call
 */
- (void)viewDidLoad
{	
	[super viewDidLoad];
	
    
    NUXHierarchy * suiteHierarchy = [NUXHierarchy hierarchyWithName:@"test"];
    self.currentDocument = [suiteHierarchy nodeWithRef:kNuxeoPathInitial];
    NSArray * docs = [suiteHierarchy childrenOfDocument:@"dac9ef1d-0ca0-4946-93ed-048021b506d9"];
    
    //if (self.path != nil)
    {
        NUXSession * nuxSession = [NUXSession sharedSession];
        {
            // Request by path
            NUXRequest * nuxRequest = [nuxSession requestChildren:kNuxeoPathInitial];
            // Request by docId
            //NUXRequest * nuxRequest = [nuxSession requestChildren:@"dac9ef1d-0ca0-4946-93ed-048021b506d9"];
            // Add schema on request
            // [nuxRequest addSchemas:@[@"dublincore", @"uid", @"file", @"common"]];
            
            [nuxRequest startWithCompletionBlock:^(NUXRequest * pRequest)
             {
                 // JSON
                 //NSDictionary * jsonResult = [pRequest responseJSONWithError:&error];
                 //documents = [[jsonResult objectForKey:@"entries"] retain];
                 NSError * error = nil;
                 NUXDocument * result = [NUXJSONSerializer entityWithData:[pRequest responseData] error:&error];
                 documents = [[result valueForKey:@"_entries"] retain];
                 
                 [self.documentsView reloadData];
                 
             } FailureBlock:^(NUXRequest * pRequest)
             {
                 
             }];
        }
    }
    
}

/**
 * Called after the viewWillAppear call
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
}

/**
 * Called after the viewDidAppear call
 */
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
}

#pragma mark -
#pragma mark Events
#pragma mark -



#pragma mark -
#pragma mark Cell Events
#pragma mark -

- (void)onTouchPreview:(NSIndexPath *)indexPath
{
    NUXDocument * nuxDocument = [self documentByIndexPath:indexPath];
    
    [CONTROLLER_HANDLER pushPreviewControllerFrom:self options:@{kBrowsePreviewViewControllerParamKeyDocument : nuxDocument}];
}

- (void)onTouchOpenWith:(NSIndexPath *)indexPath
{
    NUXDocument * nuxDocument = [self documentByIndexPath:indexPath];
    
    if([[NUXBlobStore instance] hasBlobFromDocument:nuxDocument metadataXPath:kXPathFileContent] == YES)
    {
        DocumentCellView * selectedCell = (DocumentCellView *)[self.documentsView cellForRowAtIndexPath:indexPath];
        NSString * blobPath = [[NUXBlobStore instance] blobFromDocument:nuxDocument metadataXPath:kXPathFileContent];
        NSString * mimeType = [[nuxDocument.properties objectForKey:kXPathFileContent] objectForKey:@"mime-type"];
        
        [self openWithShow:blobPath mimeType:mimeType fromView:selectedCell.openWith];
    }
}

- (void)onTouchUpdate:(NSIndexPath *)indexPath
{
    DocumentCellView * selectedCell = (DocumentCellView *)[self.documentsView cellForRowAtIndexPath:indexPath];
    [selectedCell beginUpdate];
    NUXDocument * nuxDocument = [self documentByIndexPath:indexPath];
    
    NUXSession * nuxSession = [NUXSession sharedSession];
    NUXRequest *request = [nuxSession requestDownloadBlobFrom:nuxDocument.uid
                                                   inMetadata:kXPathFileContent];
    NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tempfile%d.tmp", arc4random()]];
    request = [nuxSession requestDownloadBlobFrom:nuxDocument.uid inMetadata:kXPathFileContent];
    request.downloadDestinationPath = tempFile;
    [request setCompletionBlock:^(NUXRequest *request) {
        [[NUXBlobStore instance] saveBlobFromPath:tempFile withDocument:nuxDocument metadataXPath:kXPathFileContent error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
        
        DocumentCellView * selectedCell = (DocumentCellView *)[self.documentsView cellForRowAtIndexPath:indexPath];
        [selectedCell finishUpdate];
        
    }];
    
    [request start];
}


#pragma mark -
#pragma mark UITableViewDataSource
#pragma mark -


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (documents != nil)
    {
        return [documents count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentCellView * cell = [tableView dequeueReusableCellWithIdentifier:kDocumentTableCellReuseKey forIndexPath:indexPath];
    
    if ([documents count] > 0)
    {
        NUXDocument * selectedDocument = [documents objectAtIndex:indexPath.row];
        cell.title.text = @"test";//[selectedDocument.properties objectForKey:kDublinCoreTitle];
        
        [cell setTarget:self forIndexPath:indexPath];
        
        cell.picto.image = [super computePictoForDocument:selectedDocument];
        cell.backgroundColor = [UIColor clearColor];
        [cell localizeRecursively];
        
        BOOL fileExist = [[NUXBlobStore instance] hasBlobFromDocument:selectedDocument metadataXPath:kXPathFileContent];
        [cell.preview setEnabled:fileExist];
        [cell.openWith setEnabled:fileExist];
        
        [cell.update setHidden:![APP_DELEGATE isNetworkConnected]];
        
    }
    
    return cell;
    
}

#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
   
}

#pragma mark -
#pragma mark UIViewController
#pragma mark -

#pragma mark Basics

- (void)dealloc
{
    [_documentsView release];
    
    self.docController = nil;
    
    [documents release];
    documents = nil;
    
	[super dealloc];
}

@end
