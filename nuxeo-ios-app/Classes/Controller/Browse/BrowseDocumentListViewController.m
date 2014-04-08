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
    return [documents objectAtIndex:indexPath.row];
}

- (void) loadBusinessObjects
{
    if ([self.context isEqualToString:kBrowseDocumentOnLine])
    {
        NUXSession * nuxSession = [NUXSession sharedSession];
        {
            // Request by path
            NUXRequest * nuxRequest = [nuxSession requestChildren:self.currentDocument.uid];
            
            [nuxRequest startWithCompletionBlock:^(NUXRequest * pRequest)
             {
                 NSError * error = nil;
                 NUXDocuments * result = [NUXJSONSerializer entityWithData:[pRequest responseData] error:&error];
                 documents = [result.entries retain];
                 
                 [self.documentsView reloadData];
                 
             } FailureBlock:^(NUXRequest * pRequest)
             {
                 
             }];
        }
    }
    else if ([self.context isEqualToString:kBrowseDocumentOffLine])
    {
        self.currentDocument = [self.currentHierarchy nodeWithRef:self.currentDocument.path];
        
        if (self.currentDocument.path != nil)
        {
//            documents = [[NSMutableArray arrayWithArray:[self.currentHierarchy childrenOfDocument:self.currentDocument.path]] mutableCopy];
            documents = [[NSMutableArray array] retain];
            
            NSArray * filesOfDocument = [self.currentHierarchy contentOfDocument:self.currentDocument];
            [documents addObjectsFromArray:filesOfDocument];
            
            for (NUXDocument * nuxDocument in documents)
            {
                if ([nuxDocument.properties objectForKey:@"empty"] == nil)
                {
                    BOOL isEmpty = ![self.currentHierarchy hasContentUnderNode:nuxDocument.uid];
                    [nuxDocument.properties setObject:[NSNumber numberWithBool:isEmpty] forKey:@"empty"];
                }
            }
            
            [self.documentsView reloadData];
        }
    }
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
	
    if (self.currentDocument == nil)
    {
        NUXHierarchy * suiteHierarchy = [NUXHierarchy hierarchyWithName:@"NuxeoDriveRoot"];
        self.currentDocument = [suiteHierarchy nodeWithRef:kNuxeoPathInitial];
    }

    [self loadBusinessObjects];
    
}

/**
 * Called after the viewWillAppear call
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    self.documentPath.text = [self.path componentsJoinedByString:@" > "];
    
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

- (void)onTouchInfo:(NSIndexPath *)indexPath
{
    NUXDocument * selectedDocument = [self documentByIndexPath:indexPath];
    
    [CONTROLLER_HANDLER pushDetailDocumentInfoControllerFrom:self options:@{kParamKeyDocument: selectedDocument}];
}

- (void)onTouchPin:(NSIndexPath *)indexPath
{
    NUXDocument * nuxDocument = [self documentByIndexPath:indexPath];
    
    
}

- (void)onTouchAddSynch:(NSIndexPath *)indexPath
{
    NUXDocument * nuxDocument = [self documentByIndexPath:indexPath];
    
//    if ([nuxDocument isDriveSynchronizedFolder] == YES)
//    {
//        [[NuxeoDriveRemoteServices instance] removeSynchronizePoint:nuxDocument.path
//                                                 completionBlock:^(id result) {
//                                                     
//                                                 }];
//    }
//    else
    {
        [[NuxeoDriveRemoteServices instance] addSynchronizePoint:nuxDocument.path
                                                 completionBlock:^(id result) {
                                                     
                                                 }];
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
        cell.title.text = selectedDocument.title;
        
        [cell setTarget:self forIndexPath:indexPath];
        
        cell.picto.image = [UIImage imageNamed:[selectedDocument pictoForDocument:self.context]];
        cell.backgroundColor = [UIColor clearColor];
        [cell localizeRecursively];
        
        if ([selectedDocument isFolder] == YES)
        {
            [cell updateDisplayForFolder:selectedDocument];
        }
        else
        {
            [cell updateDisplayForFile:selectedDocument];
        }
    }
    
    return cell;
    
}

#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
   
    NUXDocument * selectedDocument = [self documentByIndexPath:indexPath];
    if ([self.context isEqualToString:kBrowseDocumentOnLine])
    {
        if ([selectedDocument isFolder] == YES)
        {
            [CONTROLLER_HANDLER pushDocumentsControllerFrom:self options:@{kParamKeyDocument: selectedDocument, kParamKeyContext : self.context}];
        }
        else
        {
            [CONTROLLER_HANDLER pushPreviewControllerFrom:self options:@{kParamKeyDocument: selectedDocument, kParamKeyContext : self.context}];
        }
    }
    else if ([self.context isEqualToString:kBrowseDocumentOffLine])
    {
        if ([selectedDocument isFolder] == YES)
        {
            [CONTROLLER_HANDLER pushDocumentsControllerFrom:self options:@{kParamKeyDocument: selectedDocument , kParamKeyHierarchy : self.currentHierarchy, kParamKeyContext : self.context}];
        }
        else
        {
            [CONTROLLER_HANDLER pushPreviewControllerFrom:self options:@{kParamKeyDocument: selectedDocument, kParamKeyContext : self.context}];
        }
    }
    
    
}

#pragma mark -
#pragma mark UIViewController
#pragma mark -

#pragma mark Basics

- (void)dealloc
{
    [_documentsView release];
    
    [_context release];
    [_path release];
    [_currentHierarchy release];
    [_currentDocument release];
    
    self.docController = nil;
    
    [documents release];
    documents = nil;
    
    [_documentPath release];
	[super dealloc];
}

@end
