//
//  NuxeoDriveAppDelegate.m
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

#import "NuxeoDriveAppDelegate.h"

#import "WelcomeViewController.h"
#import "HomeViewController.h"

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXSession+requests.h>
#import <NuxeoSDK/NUXBlobStore.h>
#import <NuxeoSDK/NUXTokenAuthenticator.h>

#import "NuxeoSettingsManager.h"
#import "NuxeoDriveRemoteServices.h"

#import "Reachability.h"

#pragma mark -
#pragma mark NuxeoDriveAppDelegate(Private)

@interface NuxeoDriveAppDelegate(Private)

@end

#pragma mark -
#pragma mark NuxeoDriveAppDelegate

@implementation NuxeoDriveAppDelegate

@synthesize isNetworkConnected, isWifiConnected;


#pragma mark -
#pragma mark NuxeoDriveAppDelegate
#pragma mark -

- (void)reachabilityChanged:(NSNotification*)notification
{
    Reachability* reachability = notification.object;
    if(reachability.currentReachabilityStatus == NotReachable)
    {
        NuxeoLogD(@"Internet off");
        isNetworkConnected = NO;
        // Stop all requests if system detect internet connection is lost
        [[NUXSession sharedSession] cancelAllRequests];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SYNC_ALL_FINISH object:nil];
    }
    else
    {
        NuxeoLogD(@"Internet on");
        isNetworkConnected = YES;
        if (reachability.currentReachabilityStatus == ReachableViaWiFi){
            isWifiConnected = YES;
        } else {
            isWifiConnected = NO;
        }
    }
}

#pragma mark -
#pragma mark NuxeoAppDelegate
#pragma mark -


#pragma mark -
#pragma mark UIApplicationDelegate
#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NuxeoLogLogo();

    // -----------------------------
    // Creating Main Window
    // -----------------------------
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    self.window.rootViewController = [[[HomeViewController alloc] init] autorelease];
    ((NuxeoDriveViewController *)self.window.rootViewController).backButtonShown = NO;


    [self.window makeKeyAndVisible];
    
    // Init
    self.syncAllEnable = NO;
    self.browseAllEnable = NO;
    self.synchronizationInProgress = [[NuxeoSettingsManager instance] readBoolSetting:SYNCHRONISATION_IN_PROGRESS defaulValue:NO];
    self.syncAllProgressStatus = 0.0;
    
    // Init NuxeoBlobStore
    // 5Go convert with http://www.convertworld.com/fr/mesures-informatiques/Gigaoctet+%28Gigabyte%29.html
    ((NUXBlobStore*)[NUXBlobStore instance]).sizeLimit = [[NuxeoSettingsManager instance] readSetting:USER_FILES_STORE_MAX_SIZE defaultValue:[NSNumber numberWithLongLong:(long long)5 * 1024 * 1024 * 1024]];
    ((NUXBlobStore*)[NUXBlobStore instance]).countLimit = [[NuxeoSettingsManager instance] readSetting:USER_FILES_COUNT_LIMIT defaultValue:@(-1)];
    
    
    return YES;
}

/**
 * Handle the url when system open the specific url scheme specify in Info.plist
 */
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	NuxeoLogD(@"url ouverte : %@", [url description]);
	
	UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NuxeoLocalized(@"application.name")
														 message:[url description]
														delegate:self
											   cancelButtonTitle:NuxeoLocalized(@"button.ok")
											   otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	
	return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	
	NSString *token = [NSString stringWithFormat:@"%@",deviceToken];
	NuxeoLogD(@"didRegisterForRemoteNotificationsWithDeviceToken", token);
	
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
	
	NuxeoLogI(@"Failed to register remote notifaction");
	NuxeoLogI(([NSString stringWithFormat: @"Error: %@", err]));
	
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
	NuxeoLogD(@"Did Receive Remote Notification");
	for (id key in userInfo)
	{
		NuxeoLogD(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
	}
	
}

/**
 * Application is "closed" by user. In fact the application go to sleep.
 */
- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 * Fired when the application wake up
 **/
- (void)applicationWillEnterForeground:(UIApplication *)application
{
	//on met à zero les badges
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Add observer for connection notifier
    [[Reachability reachabilityForInternetConnection] startNotifier];
	isNetworkConnected = [[Reachability reachabilityForInternetConnection] isReachable];
    isWifiConnected = [[Reachability reachabilityForInternetConnection] isReachableViaWiFi];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    // Nuxeo init
    NUXSession * nuxSession = [NUXSession sharedSession];
    if (nuxSession.authenticator == nil)
    {
        NUXTokenAuthenticator *auth = [[NUXTokenAuthenticator alloc] init];
        // Those fields are mandatory
        auth.applicationName = kNuxeoAppName;
        auth.permission = kNuxeoPermission;
        nuxSession.authenticator = auth;
    }
    if ([[NSUserDefaults standardUserDefaults] valueForKey:USER_HOST_URL] != nil)
    {
        [nuxSession setUrl:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:USER_HOST_URL]]];
    }
    else
    {
        [nuxSession setUrl:[NSURL URLWithString:kNuxeoSiteURL]];
    }
    [nuxSession setRepository:kNuxeoRepository];
    [nuxSession setApiPrefix:kNuxeoApiPrefix];
    [nuxSession setDownloadQueueMaxConcurrentOperationCount:2];
    // Add global schema
    [nuxSession addDefaultSchemas:@[kNuxeoSchemaDublincore, kNuxeoSchemaUid, kNuxeoSchemaFile, kNuxeoSchemaCommon, kNuxeoSchemaVideo]];
    
    // Check if a synchronization was launch and is not done
    if (APP_DELEGATE.synchronizationInProgress == YES)
    {
        [[NuxeoDriveRemoteServices instance] refreshAllSyncPoints:YES];
    }
    
    
}

@end