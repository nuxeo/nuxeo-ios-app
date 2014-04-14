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

#pragma mark - UIViewControllerLifeCycle -

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    _breadCrumbsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_section_breadcrumbs"]];

    
    [self.documentsView registerNib:[UINib nibWithNibName:NSStringFromClass([DocumentCellView class]) bundle:nil]
             forCellReuseIdentifier:NSStringFromClass([DocumentCellView class])];
    
    if (self.currentDocument == nil)
        self.currentDocument = [[NUXHierarchy hierarchyWithName:@"NuxeoDriveRoot"] nodeWithRef:kNuxeoPathInitial];
    
    [self loadBusinessObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    self.documentPath.text = [self.path componentsJoinedByString:@" > "];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark - BrowseDocumentListViewController -

- (void) reloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.documentsView reloadData];
    });
}

- (void)synchronizeAllView
{
    [super synchronizeAllView];
    [self reloadData];
}

- (NUXDocument *)documentByIndexPath:(NSIndexPath *) indexPath
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
                 documents = [result.entries mutableCopy];
                 
                 [self.documentsView reloadData];
                 
             } FailureBlock:^(NUXRequest * pRequest)
             {
                 
             }];
        }
    }
    else if ([self.context isEqualToString:kBrowseDocumentOffLine])
    {
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

#pragma mark - Cells Events -

- (void)onTouchInfo:(NSIndexPath *)indexPath
{
    [CONTROLLER_HANDLER pushDetailDocumentInfoControllerFrom:self options:@{kParamKeyDocument : [self documentByIndexPath:indexPath]}];
}

- (void)onTouchPin:(NSIndexPath *)indexPath
{
   // NUXDocument * nuxDocument = [self documentByIndexPath:indexPath];
}

- (void)onTouchAddSynch:(NSIndexPath *)indexPath
{
    NUXDocument *nuxDocument = [self documentByIndexPath:indexPath];
    [[NuxeoDriveRemoteServices instance] addSynchronizePoint:nuxDocument.path completionBlock:NULL];
}

- (void)onTouchUpdate:(NSIndexPath *)indexPath
{
    DocumentCellView * selectedCell = (DocumentCellView *)[self.documentsView cellForRowAtIndexPath:indexPath];
    [selectedCell beginUpdate];
    
    NUXDocument *nuxDocument = [self documentByIndexPath:indexPath];
    
    NUXSession *nuxSession = [NUXSession sharedSession];
    NUXRequest *request = [nuxSession requestDownloadBlobFrom:nuxDocument.uid inMetadata:kXPathFileContent];
    NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tempfile%d.tmp", arc4random()]];
    request = [nuxSession requestDownloadBlobFrom:nuxDocument.uid inMetadata:kXPathFileContent];
    request.downloadDestinationPath = tempFile;
    [request setCompletionBlock:^(NUXRequest *request) {
        [[NUXBlobStore instance] saveBlobFromPath:tempFile withDocument:nuxDocument metadataXPath:kXPathFileContent error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
        
        DocumentCellView *selectedCell = (DocumentCellView *)[self.documentsView cellForRowAtIndexPath:indexPath];
    
        [selectedCell finishUpdate];
    }];
    
    [request start];
}

#pragma mark - Delegates Implementations -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (documents != nil) ? [documents count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentCellView * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DocumentCellView class]) forIndexPath:indexPath];
    
    if (documents.count <= 0)
        return cell;
    
    NUXDocument * selectedDocument = [documents objectAtIndex:indexPath.row];
    cell.title.text = selectedDocument.title;
    
    [cell setTarget:self forIndexPath:indexPath];
    
    cell.picto.image = [UIImage imageNamed:[selectedDocument pictoForDocument:self.context]];
    cell.backgroundColor = [UIColor clearColor];
    [cell localizeRecursively];
    
    if ([selectedDocument isFolder] == YES)
        [cell updateDisplayForFolder:selectedDocument];
    else
        [cell updateDisplayForFile:selectedDocument];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
   
    NUXDocument * selectedDocument = [self documentByIndexPath:indexPath];
    if ([selectedDocument hasBinaryFile] == YES || [selectedDocument isFolder] == YES)
    {
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
}

#pragma mark - UIViewController -
#pragma mark Memory Management

- (void)dealloc
{
    NuxeoReleaseAndNil(_breadCrumbsView);
    NuxeoReleaseAndNil(documents);

    self.path = nil;
    self.context = nil;
    self.currentDocument = nil;
    self.currentHierarchy = nil;
    
    self.documentsView = nil;
    self.documentPath = nil;
	
    // NuxeoDriveViewController
    self.docController = nil;
    
    [super dealloc];
}

@end
