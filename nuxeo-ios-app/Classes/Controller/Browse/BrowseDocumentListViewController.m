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

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXSession+requests.h>
#import <NuxeoSDK/NUXDocuments.h>
#import <NuxeoSDK/NUXDocument.h>
#import <NuxeoSDK/NUXBlobStore.h>
#import <NuxeoSDK/NUXHierarchy.h>
#import <NuxeoSDK/NUXJSONSerializer.h>

#import "NuxeoDriveUtils.h"
#import "NuxeoDriveRemoteServices.h"

#import "BrowseDocumentListViewController.h"

#import "DocumentCellView.h"
#import "BreadCrumbsCellView.h"

#import "NUXDocument+Utils.h"

#define kDocumentTableCellReuseKey @"DocumentCell"
#define kSectionHeaderHeight       45.0
#define kFooterHeight              200.0

@implementation BrowseDocumentListViewController

#pragma mark - Initializers

- (void)setup
{
    [super setup];
    
    self.context = kBrowseDocumentOnLine;
    self.breadCrumbs = [NSMutableArray array];
    
    self.currentDocument = nil;
    self.currentHierarchy = nil;
    
    _documents = nil;
}

#pragma mark - UIViewControllerLifeCycle -

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    _breadCrumbsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_section_breadcrumbs"]];
    _breadCrumbsView.layer.opaque = NO;
    _breadCrumbsView.opaque = NO;
    
    [_documentsTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DocumentCellView class]) bundle:nil]
             forCellReuseIdentifier:NSStringFromClass([DocumentCellView class])];
    [_breadCrumbsCollection registerNib:[UINib nibWithNibName:NSStringFromClass([BreadCrumbsCellView class]) bundle:nil]
             forCellWithReuseIdentifier:NSStringFromClass([BreadCrumbsCellView class])];
    
    ((UICollectionViewFlowLayout *)_breadCrumbsCollection.collectionViewLayout).minimumInteritemSpacing = 2;
    
    if (self.currentDocument == nil)
        self.currentDocument = [[NUXHierarchy hierarchyWithName:@"NuxeoDriveRoot"] nodeWithRef:kNuxeoPathInitial];
    
    [self loadBusinessObjects];
    [self.view localizeRecursively];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

    if (self.currentDocument != nil)
    {
        if (![self.breadCrumbs containsObject:self.currentDocument])
        [self.breadCrumbs addObject:self.currentDocument];
    }
    
    [_breadCrumbsCollection reloadData];
    [_breadCrumbsCollection.collectionViewLayout invalidateLayout];
    
    [_emptyNotice sizeToFit];
    _emptyNotice.center = (CGPoint){self.view.center.x, self.view.center.y - CGRectGetMinY(self.contentView.frame)};
    _emptyNotice.alpha = 0;
}

#pragma mark - BrowseDocumentListViewController -

- (void)reloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_documentsTableView reloadData];
        [_breadCrumbsCollection reloadData];
        [_breadCrumbsCollection.collectionViewLayout invalidateLayout];
    });
}

- (void)synchronizeAllView
{
    [super synchronizeAllView];
    
    [self reloadData];
}

- (NUXDocument *)documentByIndexPath:(NSIndexPath *) indexPath
{
    return [_documents objectAtIndex:indexPath.row];
}

#pragma mark - Business Object Loading -

- (void) loadBusinessObjects
{
    if ([self.context isEqualToString:kBrowseDocumentOnLine])
        [self loadOnlineDocumentArray];
    else if ([self.context isEqualToString:kBrowseDocumentOffLine])
        [self loadOfflineDocumentArray];
}

- (void)loadOnlineDocumentArray
{
    NUXRequest * nuxRequest = [[NUXSession sharedSession] requestChildren:self.currentDocument.uid];
    
    [nuxRequest startWithCompletionBlock:^(NUXRequest * pRequest) {
        NSError * error = nil;
        NUXDocuments * result = [NUXJSONSerializer entityWithData:[pRequest responseData] error:&error];
        _documents = [result.entries mutableCopy];
        
        [_documentsTableView reloadData];
        
        [UIView animateWithDuration:1 animations:^{
            _documentsTableView.alpha = (_documents.count == 0) ? 0 : 1;
            _emptyNotice.alpha = (_documents.count == 0) ? 1 : 0;
        }];
        
    } FailureBlock:nil];
}

- (void)loadOfflineDocumentArray
{
    if (!self.currentDocument.path)
        return ;
    
    _documents = [[NSMutableArray alloc] init];
    [_documents addObjectsFromArray:[self.currentHierarchy contentOfDocument:self.currentDocument]];
    
    for (NUXDocument * nuxDocument in _documents)
        if ([nuxDocument.properties objectForKey:@"empty"] == nil)
        {
            BOOL isEmpty = ![self.currentHierarchy hasContentUnderNode:nuxDocument.uid];
            [nuxDocument.properties setObject:[NSNumber numberWithBool:isEmpty] forKey:@"empty"];
        }
    
    [UIView animateWithDuration:1 animations:^{
        _documentsTableView.alpha = (_documents.count == 0) ? 0 : 1;
        _emptyNotice.alpha = (_documents.count == 0) ? 1 : 0;
    }];
    
    [_documentsTableView reloadData];
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
    [[NuxeoDriveRemoteServices instance] addSynchronizePoint:[self documentByIndexPath:indexPath].path completionBlock:nil];
}

- (void)onTouchUpdate:(NSIndexPath *)indexPath
{
    DocumentCellView * selectedCell = (DocumentCellView *)[_documentsTableView cellForRowAtIndexPath:indexPath];
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
        
        DocumentCellView *selectedCell = (DocumentCellView *)[_documentsTableView cellForRowAtIndexPath:indexPath];
    
        [selectedCell finishUpdate];
    }];
    
    [request start];
}

#pragma mark - Delegates Implementations -
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.breadCrumbs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NUXDocument *objectAtIndex = nil;
    BreadCrumbsCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BreadCrumbsCellView class])
                                                                           forIndexPath:indexPath];

    if (self.breadCrumbs.count < indexPath.row || !(objectAtIndex = self.breadCrumbs[indexPath.row]) ||
        ![objectAtIndex isKindOfClass:[NUXDocument class]])
        return cell;
    
    cell.crumbsText.text = ([objectAtIndex isRoot] == YES) ? NuxeoLocalized(@"welcome.root.title") : objectAtIndex.title ;

    cell.crumbsIndicator.text = (indexPath.row == 0) ? @"::" : @">";
    [cell.crumbsIndicator  sizeToFit];
    cell.crumbsIndicator.center = (CGPoint){cell.crumbsIndicator.center.x, cell.center.y};
    
    return cell;
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)test:(NSArray *)crumbs atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger minBreadCrumbSize_ = 15;
    NSInteger maxBreadCrumbSize_ = 914;
    NSInteger totalBreadCrumbSize_ = 0;
    
    for (NUXDocument *value in self.breadCrumbs)
        totalBreadCrumbSize_ += ceilf([BreadCrumbsCellView contentSizeWithText:((NUXDocument *)value).title].width);
    
    NSInteger cropIndexs_ = floorf((totalBreadCrumbSize_ - maxBreadCrumbSize_) / minBreadCrumbSize_);
    NSInteger cropRest_ = (totalBreadCrumbSize_ - maxBreadCrumbSize_) % minBreadCrumbSize_;
    NuxeoLogD(@"Testing (%d): crop (%d) - rest (%d)", totalBreadCrumbSize_, cropIndexs_, (totalBreadCrumbSize_ - maxBreadCrumbSize_) % minBreadCrumbSize_);
    
    if (cropIndexs_ && ((indexPath.row < cropIndexs_) || (indexPath.row == cropIndexs_ && cropRest_ < minBreadCrumbSize_)))
        return (CGSize){minBreadCrumbSize_, 42};
    else if (cropIndexs_ && indexPath.row == cropIndexs_)
        return (CGSize){cropRest_, 42};
    else
        return (CGSize){[BreadCrumbsCellView contentSizeWithText:((NUXDocument *)self.breadCrumbs[indexPath.row]).title].width, 42};
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * breadCrumpLabel = ([((NUXDocument *)self.breadCrumbs[indexPath.row]) isRoot] == YES) ? NuxeoLocalized(@"welcome.root.title") :
    ((NUXDocument *)self.breadCrumbs[indexPath.row]).title;
    
    if (([((NUXDocument *)self.breadCrumbs[indexPath.row]) isRoot] == YES))
        ((NUXDocument *)self.breadCrumbs[indexPath.row]).title = NuxeoLocalized(@"welcome.root.title");
    
    NuxeoLogD(@"So what size do we have here: %@", NSStringFromCGSize([self test:self.breadCrumbs atIndexPath:indexPath]));
    
    return [self test:self.breadCrumbs atIndexPath:indexPath];
    return (CGSize){[BreadCrumbsCellView contentSizeWithText:breadCrumpLabel].width, 42};
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:[collectionView indexPathsForSelectedItems][0] animated:YES];
    
    NUXDocument *selectedDocument = self.breadCrumbs[indexPath.row];
    if ([selectedDocument hasBinaryFile] || ![selectedDocument isFolder])
        return ;
    
    NSInteger popNumber_ = (self.breadCrumbs.count - (indexPath.row + 1));
    
    NSMutableArray *newBreadCrumbs = [NSMutableArray arrayWithArray:self.breadCrumbs];
    [newBreadCrumbs removeObjectsInRange:(NSRange){indexPath.row, popNumber_}];
    
    UIViewController *cheatDismiss_ = self;
    for (int i = 0; i < popNumber_; i++)
    {
        cheatDismiss_ = cheatDismiss_.presentingViewController;
        [cheatDismiss_ dismissViewControllerAnimated:NO completion:NULL];
    }

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_documents != nil) ? [_documents count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentCellView * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DocumentCellView class]) forIndexPath:indexPath];
    
    if (_documents.count <= 0)
        return cell;
    
    NUXDocument * selectedDocument = [_documents objectAtIndex:indexPath.row];
    cell.title.text = selectedDocument.title;
    
    [cell setTarget:self forIndexPath:indexPath];
    
    cell.picto.image = [UIImage imageNamed:[selectedDocument pictoForDocument:self.context]];
    cell.backgroundColor = [UIColor clearColor];
    [cell localizeRecursively];
    
    [cell.update setHidden:[self.context isEqualToString:kBrowseDocumentOnLine]];
    
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
    if (![selectedDocument hasBinaryFile] && ![selectedDocument isFolder])
        return ;
    
    if ([APP_DELEGATE isNetworkConnected] == YES || [self.context isEqualToString:kBrowseDocumentOffLine])
    {
        // ignore context, pass as much informations as possibles (even if nil)
        if ([selectedDocument isFolder])
            [CONTROLLER_HANDLER pushDocumentsControllerFrom:self options:@{kParamKeyDocument: selectedDocument , kParamKeyHierarchy :  self.currentHierarchy ? : [NSNull null]}];
        else
            [CONTROLLER_HANDLER pushPreviewControllerFrom:self options:@{kParamKeyDocument: selectedDocument}];
    }
    else
    {
        [UIAlertView showWithTitle:NuxeoLocalized(@"application.name")
                           message:NuxeoLocalized(@"application.notconnected")
                 cancelButtonTitle:NuxeoLocalized(@"button.ok")
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              // Go to home
                              NSInteger popNumber_ = self.breadCrumbs.count;
                              
                              UIViewController *cheatDismiss_ = self;
                              for (int i = 0; i < popNumber_; i++)
                              {
                                  cheatDismiss_ = cheatDismiss_.presentingViewController;
                                  [cheatDismiss_ dismissViewControllerAnimated:NO completion:NULL];
                              }
                          }];
    }
}

#pragma mark - UIViewController -
#pragma mark Memory Management

- (void)dealloc
{
    NuxeoReleaseAndNil(_breadCrumbsView);
    NuxeoReleaseAndNil(_breadCrumbsCollection);
    
    NuxeoReleaseAndNil(_documentsTableView)
    NuxeoReleaseAndNil(_documents);

    self.breadCrumbs = nil;
    self.context = nil;
    self.currentDocument = nil;
    self.currentHierarchy = nil;
    
    [super dealloc];
}

@end
