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

#import "NuxeoFormViewController.h"

@interface NuxeoDriveViewController ()

@property (retain, nonatomic) UIView *contentView;

@end

NSString* const kMainBackgroundResourceName = @"background";
NSString* const kBackButtonResourceName = @"bt_header_back";

#pragma mark - NuxeoDriveViewController -
@implementation NuxeoDriveViewController
#pragma mark - Initializers -

- (instancetype)init
{
    if ((self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]))
        [self setup];
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
        [self setup];
    return self;
}

- (void)setup
{
    self.abstractView = YES;
}

#pragma mark - UIViewControllerLifeCycle -

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    // Abstract Header/Navigation Bar
    if (self.abstractView)
    {
        self.contentView = self.view;
        self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.applicationFrame];
        self.view.backgroundColor = self.contentView.backgroundColor;
    }
    
	[self onSetupBackground];
    
    [self onSetupHeaderBar];
    [self onSetupDisplay];
    [self onSetupFooterBar];
	
    [self onSetupLocalization];
    
    // Add observer for NOTIF_SYNC_ALL_BEGIN, NOTIF_SYNC_ALL_FINISH
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizeAllView:) name:NOTIF_SYNC_ALL_BEGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizeAllView:) name:NOTIF_SYNC_ALL_FINISH object:nil];
    
    // Add observer for connection notifier
    [[Reachability reachabilityForInternetConnection] startNotifier];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_REFRESH_UI object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self synchronizeAllView];
    }];
    
    // View&Controller Prepared & Ready
    [self retrieveBusinessObjects];
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

#pragma mark - OnSetups Helpers -

- (void)onSetupBackground
{
    if (![self.view.backgroundColor isEqual:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]])
        return ;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackgroundResourceName]];
    self.contentView.backgroundColor = self.view.backgroundColor;
}

-(void)onSetupHeaderBar
{
    if (self.headerHidden)
        return ;

    // bar custom
    _navBarCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLandscapeScreenWidth, kCustomNavigationBarHeight)];
    _navBarCustomView.tag = kHeaderBarViewTagIndex;
    _navBarCustomView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *navBarBackground_ = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_section"]] autorelease];
    navBarBackground_.image = [navBarBackground_.image resizableImageWithCapInsets:UIEdgeInsetsZero];
    navBarBackground_.frame = (CGRect){CGPointZero, CGRectGetWidth(_navBarCustomView.frame), CGRectGetHeight(navBarBackground_.frame)};
    [_navBarCustomView addSubview:navBarBackground_];
    
    UIImageView * headerLogo_ = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_logo_header"]] autorelease];
    headerLogo_.frame = (CGRect){0, CGRectGetMidY(_navBarCustomView.frame) - CGRectGetMidY(headerLogo_.frame), headerLogo_.frame.size};
    
    UIButton *logoButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    logoButton_.frame = CGRectMake(53, 0, CGRectGetWidth(headerLogo_.frame), CGRectGetHeight(_navBarCustomView.frame));
    
    [logoButton_ addSubview:headerLogo_];
    [_navBarCustomView addSubview:logoButton_];
    
    // left button
    if (self.backButtonShown == YES)
    {
        [logoButton_ addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton * buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonLeft setImage:[UIImage imageNamed:kBackButtonResourceName] forState:UIControlStateNormal];
        [buttonLeft addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        buttonLeft.frame = (CGRect){0, 0, 60, 60};
        [_navBarCustomView addSubview:buttonLeft];
    }
    
    // Header button bar
    [self addHeaderButtonBar:_navBarCustomView];
    [self.view addSubview:_navBarCustomView];
}

- (void)onSetupDisplay
{
    self.contentView.frame = (CGRect){0, CGRectGetMaxY(_navBarCustomView.frame), self.contentView.frame.size};
    self.contentView.clipsToBounds = YES;
    
    self.view.autoresizesSubviews = NO;
    if ([self.view.subviews indexOfObject:self.contentView] == NSNotFound)
        [self.view insertSubview:self.contentView belowSubview:_navBarCustomView];
}

-(void)onSetupFooterBar
{
    if (self.footerHidden)
        return ;

    // Add footer view
    _footerBarCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, kLandscapeScreenHeight - kCustomFooterBarHeight, kLandscapeScreenWidth, kCustomFooterBarHeight)];
    _footerBarCustomView.tag = kFooterViewTagIndex;
    _footerBarCustomView.backgroundColor = COLOR_DARK_BLUE;
    [self.view addSubview:_footerBarCustomView];
}

- (void)onSetupLocalization
{
	[self.view localizeRecursively];
}

#pragma mark - Design Helpers -

- (void)addHeaderButtonBar:(UIView *)navBarCustomView
{
    CGPoint kButtonPoint_ = (CGPoint){760, 0};
    CGSize kButtonSize_ = (CGSize){60, 60};
    float kButtonMargin = 5.f;
    
    NSArray *buttonDictionary_ = @[@[@"pinButton", @"bt_header_cloud", @"onTouchBrowseOnDevice:"],
                                   @[@"searchButton", @"bt_header_find", @"onTouchSearch:"],
                                   @[@"updateAllButton", @"bt_header_update", @"onTouchUpdateAll:"],
                                   @[@"settingsButton", @"bt_header_settings", @"onTouchSettings:"],
                                   ];
    
    for (NSArray *button_ in buttonDictionary_)
    {
        NuxeoButton *nuxeoButton_ = [NuxeoButton buttonWithType:UIButtonTypeCustom];
        
        nuxeoButton_.frame = (CGRect){kButtonPoint_, kButtonSize_};
        kButtonPoint_.x += kButtonSize_.width + kButtonMargin;
        
        nuxeoButton_.backgroundColor = [UIColor clearColor];
        [nuxeoButton_ setImage:[UIImage imageNamed:button_[1]] forState:UIControlStateNormal];
        [nuxeoButton_ setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", button_[1]]] forState:UIControlStateHighlighted];
        [nuxeoButton_ setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", button_[1]]] forState:UIControlStateSelected];
        [nuxeoButton_ addTarget:self action:NSSelectorFromString(button_[2]) forControlEvents:UIControlEventTouchUpInside];
     
        [navBarCustomView addSubview:nuxeoButton_];
        [self setValue:nuxeoButton_ forKeyPath:button_[0]];
    }
    
    [self synchronizeAllView];
}

#pragma mark - NuxeoDriveViewController

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

- (void) checkAuthentication
{
	// Check Authentication
    NUXSession *session = [NUXSession sharedSession];
    if ([session.authenticator softAuthentication] == NO || session.authenticator == nil)
    {
        // Otherwise; Present Logout
        [self logout];
    }
    else
    {
        // Check if token is not revoked
        // Request by path
        NUXRequest * nuxRequest = [[NUXSession sharedSession] requestDocument:kNuxeoPathInitial];
        [nuxRequest startWithCompletionBlock:^(NUXRequest * pRequest)
         {
             if ([pRequest responseStatusCode] != 200)
             {
                 [self logout];
             }
             
         } FailureBlock:^(NUXRequest * pRequest)
         {
             if ([pRequest responseStatusCode] == 401 && [APP_DELEGATE isNetworkConnected] == YES)
             {
                 [self logout];
             }
         }];
    }
}

- (void) retrieveBusinessObjects
{
    
}

- (void) synchronizeAllView
{
    //[self.searchButton setEnabled:[APP_DELEGATE isNetworkConnected]];
    [self.updateAllButton setEnabled:[APP_DELEGATE isNetworkConnected]];
    
    if (APP_DELEGATE.synchronizationInProgress == YES && [APP_DELEGATE isNetworkConnected] == YES)
    {
        // animate the update button
        // [self.updateAllButton setEnabled:NO];
        [self runSpinAnimationOnView:self.updateAllButton duration:1.f];
    }
    else
    {
        // stop animation of update button
        [self stopSpinAnimationOnView:self.updateAllButton];
    }
}

- (UIView *) headerBarView
{
    return _navBarCustomView;
}

- (UIView *) footerBarView
{
    return _footerBarCustomView;
}

- (UIView *) backgroundView
{
    return self.view;
}

#pragma mark - Events -

- (void) goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) onTouchUpdateAll:(id)sender
{
    [[NuxeoDriveRemoteServices instance] refreshAllSyncPoints:YES];
}

- (void) onTouchBrowseOnDevice:(id)sender
{
    [[NuxeoDriveControllerHandler instance] pushBrowseOnDeviceControllerFrom:self options:nil];
}

- (void) onTouchSearch:(id)sender
{
    [[NuxeoDriveControllerHandler instance] pushAllDocumentsOfflineControllerFrom:self options:nil];
}

- (void) onTouchSettings:(id)sender
{
    [[NuxeoDriveControllerHandler instance] pushSettingsControllerFrom:self options:nil];
}


#pragma mark - Notification selectors -

- (void)synchronizeAllView:(NSNotification*)notification
{
    [self synchronizeAllView];
}

- (void)reachabilityChanged:(NSNotification*)notification
{
    Reachability* reachability = notification.object;
    
    if (reachability.currentReachabilityStatus == NotReachable)
    {
        NuxeoLogD(@"Internet off");
    }
    else
    {
        NuxeoLogD(@"Internet on");
    }
    
    [self synchronizeAllView];
}


#pragma mark - Animations -

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration;
{
    if ([view.layer animationForKey:@"SpinAnimation"])
        return ;
        
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @0.0f;
    animation.toValue = @(2 * M_PI);
    animation.duration = duration;
    animation.repeatCount = HUGE_VALF;
    [view.layer addAnimation:animation forKey:@"SpinAnimation"];
}

-(void) stopSpinAnimationOnView:(UIView *)view
{
    [view.layer removeAllAnimations];
}

#pragma mark Events

- (void) logout
{
    NUXSession * nuxSession = [NUXSession sharedSession];
    if (nuxSession.authenticator != nil)
    {
        [((NUXTokenAuthenticator *)nuxSession.authenticator) resetSettings];
        
    }
    UIViewController *cheatDismiss_ = self;
    while (cheatDismiss_.presentingViewController != nil)
    {
        cheatDismiss_ = cheatDismiss_.presentingViewController;
        [cheatDismiss_ dismissViewControllerAnimated:NO completion:NULL];
    }
    [cheatDismiss_ presentViewController:[[[WelcomeViewController alloc] init] autorelease] animated:YES completion:NULL];
    //[self presentViewController:[[[WelcomeViewController alloc] init] autorelease] animated:YES completion:NULL];
}

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

#pragma mark - UIViewController -
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

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
	NuxeoLogW(@"");
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NuxeoReleaseAndNil(_navBarCustomView);
    NuxeoReleaseAndNil(_footerBarCustomView);
    
    self.pinButton = nil;
    self.searchButton = nil;
    self.updateAllButton = nil;
    self.settingsButton = nil;
    
    self.docController = nil;
    self.contentView = nil; // Private Interface
    
    [super dealloc];
}

@end
