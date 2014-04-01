//
//  NuxeoDriveViewController.h
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

#define kBackgroundViewTagIndex             1000
#define kHeaderBarViewTagIndex              1001
#define kFooterViewTagIndex                 1002

#define kCustomNavigationBarHeight          60
#define kCustomFooterBarHeight              50

#import "NuxeoDriveViewController.h"
#import "WelcomeViewController.h"

#import "NuxeoButton.h"
#import "NuxeoLabel.h"

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXSession+requests.h>
#import <NuxeoSDK/NUXDocument.h>
#import <NuxeoSDK/NUXDocuments.h>
#import <NuxeoSDK/NUXHierarchy.h>
#import <NuxeoSDK/NUXBlobStore.h>
#import <NuxeoSDK/NUXTokenAuthenticator.h>

#import "NuxeoDriveRemoteServices.h"

#import "NuxeoDriveUtils.h"

#import "Reachability.h"

#import "UIAlertView+Blocks.h"


#pragma mark -
#pragma mark NuxeoDriveViewController

@implementation NuxeoDriveViewController

#pragma mark -
#pragma mark NuxeoDriveViewController

- (void) openWithShow:(NSString *)docPath mimeType:(NSString *)mimeType fromView:(UIView *)iView
{
    self.docController = nil;
    self.docController = [NuxeoDriveUtils setupControllerWithURL:[NSURL fileURLWithPath:docPath] usingDelegate:self];
    
    CFStringRef MIMEType = (__bridge CFStringRef)mimeType;
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, MIMEType, NULL);
    
    self.docController.UTI = (__bridge NSString *)UTI;
    
    if([self.docController presentOpenInMenuFromRect:(CGRect){CGPointMake(NuxeoViewW(iView)/2, NuxeoViewH(iView)), CGSizeMake(0,0)} inView:iView animated:YES] == NO)
    {
        // alert what no app are installed to open this type of document
        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:NuxeoLocalized(@"application.name")
                                                          message:NuxeoLocalized(@"preview.open.with.noapp")
                                                         delegate:nil
                                                cancelButtonTitle:NuxeoLocalized(@"button.ok")
                                                otherButtonTitles:nil] autorelease];
        
        [alert show];
    }
    
}

- (NSString *) mainBackgroundResourceName
{
    return @"bg_texture";
}

- (NSString *) backButtonResourceName
{
    return @"bt_header_back";
}

- (void) checkAuthentication
{
	// Check Authentication
    NUXSession *session = [NUXSession sharedSession];
    if ([session.authenticator softAuthentication] == NO)
    {
        // Otherwise; Present Login screen
        [self presentViewController:[[WelcomeViewController alloc]initWithNibName:kXIBWelcomeController bundle:nil] animated:YES completion:^{
            
        }];
    }
}

- (void) retrieveBusinessObjects
{
    
}

- (void) synchronizeAllView
{
    if ([APP_DELEGATE isNetworkConnected] == NO)
    {
        
    }
    else
    {
    
    }
}

- (void)reachabilityChanged:(NSNotification*)notification
{
    Reachability* reachability = notification.object;
    if(reachability.currentReachabilityStatus == NotReachable)
    {
        NuxeoLogD(@"Internet off");
    }
    else
    {
        NuxeoLogD(@"Internet on");
    }
    [self synchronizeAllView];
    
}

- (void) addHeaderButtonBar:(UIView *) navBarCustomView
{
    float xButton = 760.f;
    float kButtonHeight = 60.f;
    float kButtonMargin = 5.f;
    
    {
        // Pin
        self.pinButton = [NuxeoButton buttonWithType:UIButtonTypeCustom];
        self.pinButton.frame = CGRectMake(xButton,0,kButtonHeight,kButtonHeight);
        [self.pinButton setBackgroundColor:[UIColor clearColor]];
        [self.pinButton setImage:[UIImage imageNamed:@"bt_header_star"] forState:UIControlStateNormal];
        [self.pinButton setImage:[UIImage imageNamed:@"bt_header_star_selected"] forState:UIControlStateHighlighted];
        [self.pinButton setImage:[UIImage imageNamed:@"bt_header_star_selected"] forState:UIControlStateSelected];
        [navBarCustomView addSubview:self.pinButton];
        [self.pinButton addTarget:self action:@selector(onTouchBrowseOnDevice:) forControlEvents:UIControlEventTouchUpInside];
        xButton += kButtonHeight + kButtonMargin;
    }
    
    {
        // Search
        self.searchButton = [NuxeoButton buttonWithType:UIButtonTypeCustom];
        self.searchButton.frame = CGRectMake(xButton,0,kButtonHeight,kButtonHeight);
        [self.searchButton setBackgroundColor:[UIColor clearColor]];
        [self.searchButton setImage:[UIImage imageNamed:@"bt_header_find"] forState:UIControlStateNormal];
        [self.searchButton setImage:[UIImage imageNamed:@"bt_header_find_selected"] forState:UIControlStateHighlighted];
        [self.searchButton setImage:[UIImage imageNamed:@"bt_header_find_selected"] forState:UIControlStateSelected];
        [navBarCustomView addSubview:self.searchButton];
        [self.searchButton addTarget:self action:@selector(onTouchSearch:) forControlEvents:UIControlEventTouchUpInside];
        xButton += kButtonHeight + kButtonMargin;
    }
    
    //if (self.isUpdateAllButtonShown == YES)
    {
        // Browse products
        self.updateAllButton = [NuxeoButton buttonWithType:UIButtonTypeCustom];
        self.updateAllButton.frame = CGRectMake(xButton,0,kButtonHeight,kButtonHeight);
        [self.updateAllButton setBackgroundColor:[UIColor clearColor]];
        [self.updateAllButton setImage:[UIImage imageNamed:@"bt_header_update"] forState:UIControlStateNormal];
        [self.updateAllButton setImage:[UIImage imageNamed:@"bt_header_update_selected"] forState:UIControlStateHighlighted];
        [self.updateAllButton setImage:[UIImage imageNamed:@"bt_header_update_selected"] forState:UIControlStateSelected];
        [navBarCustomView addSubview:self.updateAllButton];
        [self.updateAllButton addTarget:self action:@selector(onTouchUpdateAll:) forControlEvents:UIControlEventTouchUpInside];
        xButton += kButtonHeight + kButtonMargin;
    }
    
    {
        // Settings
        self.settingsButton = [NuxeoButton buttonWithType:UIButtonTypeCustom];
        self.settingsButton.frame = CGRectMake(xButton,0,kButtonHeight,kButtonHeight);
        [self.settingsButton setBackgroundColor:[UIColor clearColor]];
        [self.settingsButton setImage:[UIImage imageNamed:@"bt_header_settings"] forState:UIControlStateNormal];
        [self.settingsButton setImage:[UIImage imageNamed:@"bt_header_settings_selected"] forState:UIControlStateHighlighted];
        [self.settingsButton setImage:[UIImage imageNamed:@"bt_header_settings_selected"] forState:UIControlStateSelected];
        [navBarCustomView addSubview:self.settingsButton];
        [self.settingsButton addTarget:self action:@selector(onTouchSettings:) forControlEvents:UIControlEventTouchUpInside];
        xButton += kButtonHeight + kButtonMargin;
    }
    
    [self synchronizeAllView];
    
}

-(void) onSetupHeaderBar
{
    if(self.isHeaderHidden == NO)
    {
        // bar custom
        UIView * navBarCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLandscapeScreenWidth, kCustomNavigationBarHeight)];
        navBarCustomView.tag = kHeaderBarViewTagIndex;
        navBarCustomView.backgroundColor = COLOR_DARK_BLUE;
        
        // left button
        if (self.isBackButtonShown == YES)
        {
            UIButton * buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
            buttonLeft.frame = CGRectMake(0, 0, kCustomNavigationBarHeight, kCustomNavigationBarHeight);
            [buttonLeft setBackgroundImage:[UIImage imageNamed:[self backButtonResourceName]] forState:UIControlStateNormal];
            [navBarCustomView addSubview:buttonLeft];
            [buttonLeft addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
            
            UIImageView * headerLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_logo_header"]];
            UIButton * buttonLeftLogo = [UIButton buttonWithType:UIButtonTypeCustom];
            buttonLeftLogo.frame = CGRectMake(NuxeoViewX(buttonLeft) + NuxeoViewW(buttonLeft), 0, NuxeoViewW(headerLogo), kCustomNavigationBarHeight);
            headerLogo.frame = CGRectMake(NuxeoViewX(buttonLeftLogo), 0, NuxeoViewW(headerLogo), NuxeoViewH(headerLogo));
            [navBarCustomView addSubview:headerLogo];
            [navBarCustomView addSubview:buttonLeftLogo];
            [buttonLeftLogo addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        // Header button bar
        [self addHeaderButtonBar:navBarCustomView];
        
        [self.view addSubview:navBarCustomView];
        [navBarCustomView release];
    }
    
}

-(void) onSetupFooterBar
{
    if(self.isFooterHidden == NO)
    {
        // Add footer view
        UIView * footerBarCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, kLandscapeScreenHeight - kCustomFooterBarHeight, kLandscapeScreenWidth, kCustomFooterBarHeight)];
        footerBarCustomView.tag = kHeaderBarViewTagIndex;
        footerBarCustomView.backgroundColor = COLOR_DARK_BLUE;
        [self.view addSubview:footerBarCustomView];
        [footerBarCustomView release];
    }
    
}

- (void)onSetupBackground
{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[self mainBackgroundResourceName]]]];
}

- (void)onSetupDisplay
{
	
}

- (void)onSetupLocalization
{
	[self.view localizeRecursively];
}

- (UIView *) headerBarView
{
    return [self.view viewWithTag:kHeaderBarViewTagIndex];
}

- (UIView *) footerBarView
{
    return [self.view viewWithTag:kFooterViewTagIndex];
}

- (UIView *) backgroundView
{
    return [self.view viewWithTag:kBackgroundViewTagIndex];
}

#pragma Events

- (void) goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// Sync all documents
//- (void) onTouchSyncAllDocs:(id)sender
//{
//    APP_DELEGATE.syncAllEnable = NO;
//    APP_DELEGATE.syncAllProgressStatus = 0.1;
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SYNC_ALL_BEGIN object:nil];
//    
//    [self.syncButton setEnabled:NO];
//    [self.syncAllActivity startAnimating];
//    self.syncAllActivity.hidden = NO;
//    
//    NSArray * documents = [[[NuxeoDriveRemoteServices instance] retrieveAllDocumentsFromMainHierarchy] retain];
//    NSInteger __block operations = [documents count];
//    for (NUXDocument * nuxDocument in documents)
//    {
//        // If blobStore already has the blob, it is not necessary to redownload it.
//        if ([[NUXBlobStore instance] hasBlobFromDocument:nuxDocument metadataXPath:kXPathFileContent]) {
//            operations -= 1;
//            continue;
//        }
//        
//        NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tempfile%d.tmp", arc4random()]];
//        
//        NUXSession * nuxSession = [NUXSession sharedSession];
//        NUXRequest *request = [nuxSession requestDownloadBlobFrom:nuxDocument.uid
//                                                       inMetadata:kXPathFileContent];
//        request = [nuxSession requestDownloadBlobFrom:nuxDocument.uid inMetadata:kXPathFileContent];
//        request.downloadDestinationPath = tempFile;
//        request.shouldContinueWhenAppEntersBackground = YES;
//        
//        NUXBasicBlock syncAllDoneIfEmpty = ^(void) {
//            operations -= 1;
//            if (operations <= 0) {
//                [self syncAllDone];
//            }
//        };
//        
//        [request setCompletionBlock:^(NUXRequest *request) {
//            [[NUXBlobStore instance] saveBlobFromPath:tempFile withDocument:nuxDocument metadataXPath:kXPathFileContent error:nil];
//            [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
//            syncAllDoneIfEmpty();
//        }];
//        [request setFailureBlock:^(NUXRequest *request) {
//            syncAllDoneIfEmpty();
//        }];
//        
//        [request start];
//    }
//    
//    if (operations <= 0) {
//        [self syncAllDone];
//    }
//    
//    [documents release];
//}

- (void) syncAllDone
{
    dispatch_async(dispatch_get_main_queue(), ^{
        APP_DELEGATE.syncAllEnable = YES;
        APP_DELEGATE.syncAllProgressStatus = -1.0;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SYNC_ALL_FINISH object:nil];
    });
}

- (void) onTouchUpdateAll:(id)sender
{
    // TODO
    
}

- (void) onTouchBrowseOnDevice:(id)sender
{
    [[NuxeoDriveControllerHandler instance] pushBrowseOnDeviceControllerFrom:self options:nil];
    
}

- (void) onTouchSearch:(id)sender
{
    // TODO
    
}

- (void) onTouchSettings:(id)sender
{
    [[NuxeoDriveControllerHandler instance] pushSettingsControllerFrom:self options:nil];
}

#pragma mark -
#pragma mark UIViewControllerLifeCycle

- (void) loadView
{
    [super loadView];
    

}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
    // Add observer for NOTIF_SYNC_ALL_BEGIN, NOTIF_SYNC_ALL_FINISH
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizeAllView) name:NOTIF_SYNC_ALL_BEGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizeAllView) name:NOTIF_SYNC_ALL_FINISH object:nil];
    // Add observer for connection notifier
    [[Reachability reachabilityForInternetConnection] startNotifier];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [self retrieveBusinessObjects];
	
	[self onSetupBackground];
	
    [self onSetupHeaderBar];
	
    [self onSetupFooterBar];
	
    [self onSetupDisplay];
	
    [self onSetupLocalization];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
    [self checkAuthentication];
    
    [self synchronizeAllView];
}

#pragma mark -
#pragma mark UIViewControllerExceptionHandler

/*
 
 - (BOOL) onBusinessObjectException:(id<UIViewControllerLifeCycle>)aggregate exception:(NuxeoBusinessObjectException *)exception resume:(BOOL *)resume;
 - (BOOL) onLifeCycleException:(id<UIViewControllerLifeCycle>)aggregate exception:(NuxeoLifeCycleException *)exception resume:(BOOL *)resume;
 - (BOOL) onOtherException:(id<UIViewControllerLifeCycle>)aggregate exception:(NSException *)exception resume:(BOOL *)resume;
 
 */




#pragma mark -
#pragma mark UIAlertViewDelegate
#pragma mark -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // No
            break;
        case 1:
            // Yes
            
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.docController = nil;
    self.pinButton = nil;
    self.searchButton = nil;
    self.updateAllButton = nil;
    self.settingsButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	NuxeoLogW(@"");
	
	[super didReceiveMemoryWarning];
	
}

#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return DeviceOrientationSupported(interfaceOrientation);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	NuxeoLogD(@"");
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NuxeoLogD(@"");
}

// Add with iOS 6
- (BOOL) shouldAutorotate
{
    return YES;
}

@end
