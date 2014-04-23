//
//  HomeViewController.m
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

#import "HomeViewController.h"

#import <NuxeoSDK/NUXDocument.h>

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXSession+requests.h>
#import <NuxeoSDK/NUXHierarchy.h>
#import <NuxeoSDK/NUXHierarchyDB.h>
#import <NuxeoSDK/NUXBlobStore.h>
#import <NuxeoSDK/NUXTokenAuthenticator.h>
#import <NuxeoSDK/NUXJSONSerializer.h>

#import "NuxeoDriveRemoteServices.h"

#import "UIAlertView+Blocks.h"

#import "DirectoryViewCell.h"
#import "NuxeoPopoverViewController.h"

#define kBrowseReuseIdentifierForCollection     @"BrowseFolder"

@implementation HomeViewController

#pragma mark - UIViewControllerLifeCycle -

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.footerBarView.hidden = YES;
    
    [self.browsingFolders registerNib:[UINib nibWithNibName:NSStringFromClass([DirectoryViewCell class]) bundle:nil]
           forCellWithReuseIdentifier:kBrowseReuseIdentifierForCollection];
}

- (void)retrieveBusinessObjects
{
    [super retrieveBusinessObjects];
        
    self.browsingFolders.backgroundColor = [UIColor clearColor];
    NUXSession * nuxSession = [NUXSession sharedSession];
    {
        // Request by path
        NUXRequest * nuxRequest = [nuxSession requestDocument:kNuxeoPathInitial];
        [nuxRequest startWithCompletionBlock:^(NUXRequest * pRequest)
         {
             // JSON
             //NSDictionary * jsonResult = [pRequest responseJSONWithError:&error];
             //documents = [[jsonResult objectForKey:@"entries"] retain];
             NSError * error = nil;
             NUXDocument * result = [NUXJSONSerializer entityWithData:[pRequest responseData] error:&error];
             
             rootDocument = [result retain];
             
             [self.browsingFolders reloadData];
             
         } FailureBlock:^(NUXRequest * pRequest)
         {
         }];
    }
}

- (void) synchronizeAllView
{
    [super synchronizeAllView];
}

#pragma mark - HomeViewController functions -

- (void) hidePopupAction
{
    self.popupActions.hidden = YES;
}

- (void) activateHomeScreen
{
    APP_DELEGATE.syncAllEnable = YES;
    APP_DELEGATE.browseAllEnable = YES;
}

- (void) setupMainHierarchy
{
//    [[NuxeoDriveRemoteServices instance] setupAllHierarchy:^(id object) {
//        [self activateHomeScreen];
//    }];
}

- (void) loadMainHierarchy
{
    [self setupMainHierarchy];
    //[[NuxeoDriveRemoteServices instance] retrieveBrowseAllHierarchy:^(id object) {
        [self activateHomeScreen];
    //}];
}

#pragma mark - Events -

- (void) goBack:(id)sender
{
    [self logout];
}

- (IBAction)onTouchUnpin:(id)sender
{
    [self onTouchUnpinAtIndexPath:selectedDocumentIndex];
}

- (IBAction)onTouchInfo:(id)sender
{
    [self onTouchInfoButtonAtIndexPath:selectedDocumentIndex];
}

- (IBAction)onTouchRemoveFromDevice:(id)sender
{
    [self onTouchRemoveAtIndexPath:selectedDocumentIndex];
}

- (IBAction)onTouchTest:(id)sender
{
    [[NuxeoDriveRemoteServices instance] removeSynchronizePoint:@"doc:/default-domain/workspaces/Finance"
                                             completionBlock:NULL];
}

#pragma mark -
#pragma mark NuxeoDrivePopupActionViewDelegate
#pragma mark -

// Fire when user touch on info button on collectionViewCell
- (void) onTouchInfoAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.popupActions.hidden == YES || (self.popupActions.hidden == NO && selectedDocumentIndex != indexPath))
    {
        UICollectionViewCell * selectedCell = [self.browsingFolders cellForItemAtIndexPath:indexPath];
        self.popupActions.frame = (CGRect){CGPointMake(NuxeoViewX(selectedCell)-20, NuxeoViewY(selectedCell)+40),self.popupActions.frame.size};
        [[selectedCell superview] addSubview:self.popupActions];
        self.popupActions.hidden = NO;

        NuxeoReleaseAndNil(selectedDocumentIndex);
        selectedDocumentIndex = [indexPath retain];
    }
    else
    {
        if (selectedDocumentIndex == indexPath)
        {
            // hide the popup
            self.popupActions.hidden = YES;
            [self.popupActions removeFromSuperview];
        }
    }
    
}

// Fire when user touch on unpin button
- (void)onTouchUnpinAtIndexPath:(NSIndexPath *)indexPath
{
    [self hidePopupAction];
}

// Fire when user touch on info button on popup
- (void) onTouchInfoButtonAtIndexPath:(NSIndexPath *)indexPath
{
    [self hidePopupAction];
}

// Fire when user touch on remove from device button
- (void) onTouchRemoveAtIndexPath:(NSIndexPath *)indexPath
{
    [self hidePopupAction];
    
//    [[NuxeoDriveRemoteServices instance] removeSynchronizePoint:@"" completionBlock:^{
//        
//    }];
    
}

#pragma mark -
#pragma mark UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.browsingFolders])
    {
#ifdef DEBUG
        return 100;
#endif
        return 1;
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.browsingFolders])
    {
        DirectoryViewCell * cell = (DirectoryViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kBrowseReuseIdentifierForCollection forIndexPath:indexPath];
        
        [cell localizeRecursively];
        cell.indexPath = indexPath;
        
        [cell loadWithActionPopoverTitles:@[@"truc", @"truc", @"bidule"]];
        cell.delegate = self;
        
        
        [cell repositoryRendering];
        
        return cell;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.browsingFolders])
    {
        // Browse into selected folder
        if ([APP_DELEGATE isNetworkConnected] == YES)
        {
            if (rootDocument != nil)
            {
                [[NuxeoDriveControllerHandler instance] pushDocumentsControllerFrom:self options:@{kParamKeyDocument: rootDocument, kParamKeyContext : kBrowseDocumentOnLine}];
            }
            else
            {
                [[NuxeoDriveControllerHandler instance] pushDocumentsControllerFrom:self options:nil];
            }
        }
        else
        {
            [UIAlertView showWithTitle:NuxeoLocalized(@"application.name")
                                                         message:NuxeoLocalized(@"application.notconnected")
                                               cancelButtonTitle:NuxeoLocalized(@"button.ok")
                                               otherButtonTitles:nil
                                                        tapBlock:nil];
        }
    }
}

#pragma mark - NuxeoActionPopoverDelegate

- (void)actionPopoverCaller:(id)caller clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NuxeoLogD(@"Testing action popover return: %@ - %d", [_browsingFolders indexPathForCell:caller], buttonIndex);
}

#pragma mark - UIViewController -
#pragma mark Memory Management

- (void)dealloc
{
    NuxeoReleaseAndNil(selectedDocumentIndex);
    
    self.browsingFolders = nil;
    self.popupActions = nil;
    
    [super dealloc];
}

@end
