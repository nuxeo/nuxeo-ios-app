//
//  Constants.h
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


#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <CoreServices/CoreServices.h>
#endif

#import "NuxeoDriveAppDelegate.h"

#define APP_DELEGATE                ((NuxeoDriveAppDelegate *) [[UIApplication sharedApplication] delegate])
#define CONTROLLER_HANDLER          [NuxeoDriveControllerHandler instance]

#define kNuxeoScreenWidth			[[UIScreen mainScreen] applicationFrame].size.width
#define kNuxeoScreenHeight          [[UIScreen mainScreen] applicationFrame].size.height
#define kNuxeoCurrentOrientation 	[[UIApplication sharedApplication] statusBarOrientation]

#define NuxeoLocalized(s)           NSLocalizedString(s, @"")

#define DeviceOrientationSupported(orientation) UIDeviceOrientationIsLandscape(orientation) 

#define NuxeoViewX(v)               (CGRectGetMinX(v.frame))
#define NuxeoViewY(v)               (CGRectGetMinY(v.frame))
#define NuxeoViewW(v)               (CGRectGetWidth(v.frame))
#define NuxeoViewH(v)               (CGRectGetHeight(v.frame))

#define kLandscapeScreenSize        ((CGSize){1024, 768})
#define kLandscapeScreenWidth       kLandscapeScreenSize.width
#define kLandscapeScreenHeight      kLandscapeScreenSize.height

/********************************** Colors ********************************/

#define RGB(r, g, b)            [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a)        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define COLOR_HEXA(color)       [NuxeoColorUtils colorFromWebColor:color]
#define COLOR_RED               COLOR_HEXA(@"#E20014")
#define COLOR_BLUE              COLOR_HEXA(@"#009CD7")
#define COLOR_DARK_BLUE         COLOR_HEXA(@"#08132C")
#define COLOR_GREEN             COLOR_HEXA(@"#673B9A")
#define COLOR_LIGHT_GRAY        COLOR_HEXA(@"#EBECEC")

/********************************** Fonts ********************************/

// font for custom UI
#define FONT_COMMON(s)              [UIFont fontWithName:@"UniversLT" size:s]
#define FONT_COMMON_BOLD(s)         [UIFont fontWithName:@"UniversLT-Bold" size:s]
#define FONT_COMMON_BLACK(s)        [UIFont fontWithName:@"UniversLT-Black" size:s]


/********************************** Alert screen ********************************/

// Font for custom alert
#define FONT_ALERT_TITLE(s)         FONT_COMMON(s)
#define FONT_ALERT_MESSAGE(s)       FONT_COMMON(s)
#define FONT_ALERT_BUTTON(s)        FONT_COMMON(s)
// width between buttons in alert screen
#define ALERT_SEP_BUTTON ValueDeviceDepend(80.0, 10.0)


/********************************** Sounds ********************************/


/********************************** XIBs ********************************/

// Category
#define kXIBBrowseStandardViewController            @"BrowseStandardViewController"
#define kXIBBrowseDocumentListViewController        @"BrowseDocumentListViewController"
#define kXIBBrowseSuiteCategoryViewController       @"BrowseSuiteCategoryViewController"
#define kXIBBrowseOnDeviceViewController            @"BrowseOnDeviceViewController"
#define kXIBDirectoryCellView                       @"DirectoryViewCell"
#define kXIBDocumentTableCellView                   @"DocumentCellView"

#define kXIBPreviewDisplayViewController            @"PreviewDisplayViewController"

/****************************** NOTIFICATIONS ********************************/

// notifications send during synchronized point workflow
#define NOTIF_ADD_SYNC_POINT                    @"NOTIF_ADD_SYNC_POINT"
#define NOTIF_REMOVE_SYNC_POINT                 @"NOTIF_REMOVE_SYNC_POINT"
// notifications send during data synchronization of a hierarchy
// First step load hierarchy folders tree
#define NOTIF_HIERARCHY_FOLDER_TREE_DOWNLOADED  @"NOTIF_HIERARCHY_FOLDER_TREE_DOWNLOADED"
// Notification send when application end to download one file of a hierarchy
#define NOTIF_HIERARCHY_BINARY_DOWNLOADED       @"NOTIF_HIERARCHY_BINARY_DOWNLOADED"
// Notification send when all binary files of a hierarchy are downloaded
#define NOTIF_HIERARCHY_ALL_CONTENT_DOWNLOADED  @"NOTIF_HIERARCHY_ALL_CONTENT_DOWNLOADED"

// Notification send when all synchronization begin
#define NOTIF_SYNC_ALL_BEGIN                    @"NOTIF_SYNC_ALL_BEGIN"
// Notification send when all synchronization end
#define NOTIF_SYNC_ALL_FINISH                   @"NOTIF_SYNC_ALL_FINISH"

// Notification send to indicate a change in the network connection
#define NOTIF_NETWORK_STATUS_CHANGE             @"NOTIF_NETWORK_STATUS_CHANGE"
// Notification send by system to refresh User Interface
#define NOTIF_REFRESH_UI                        @"NOTIF_REFRESH_UI"

/********************************** Params ********************************/

//#define kParamModuleKey                 @"module"

#define kBrowseDocumentOnLine                   @"_"
#define kBrowseDocumentOffLine                  @"_synchro_"


/********************************** USER PREFERENCES ********************************/

#define USER_HOST_URL               @"USER_HOST_URL"
#define USER_USERNAME               @"USER_USERNAME"

#define USER_FILES_STORE_MAX_SIZE   @"USER_FILES_STORE_MAX_SIZE"
#define USER_FILES_COUNT_LIMIT      @"USER_FILES_COUNT_LIMIT"
#define USER_SYNC_OVER_CELLULAR     @"USER_SYNC_OVER_CELLULAR"

#define USER_SYNC_POINTS_LIST       @"USER_SYNC_POINTS_LIST"

#define SYNCHRONISATION_IN_PROGRESS @"SYNCHRONISATION_IN_PROGRESS"

/********************************** Math - Data ********************************/

#define kGigabyteSize   (powf(kKilobyteSize, 3.f))
#define kMegabyteSize   (powf(kKilobyteSize, 2.f))
#define kKilobyteSize   (1024.f)

/********************************** ServicesWeb ***********************************/


/********************************** NUXEO SETTINGS ********************************/
#define kNuxeoSiteURL               @"http://demo.nuxeo.com/nuxeo/"

#define kNuxeoApiPrefix             @"api/v1/"
#define kNuxeoUser                  @"Administrator"
#define kNuxeoPassword              @"Administrator"
#define kNuxeoRepository            @"default"
#define kNuxeoAppName               @"Nuxeo Drive iOS Edition"
#define kNuxeoPermission            @"ReadWrite"

#define kNuxeoURIStatus             @"runningstatus"

// global schemas
#define kNuxeoSchemaDublincore      @"dublincore"
#define kNuxeoSchemaUid             @"uid"
#define kNuxeoSchemaFile            @"file"
#define kNuxeoSchemaCommon          @"common"
#define kNuxeoSchemaVideo           @"video"

// Schema DublinCore
#define kDublinCoreTitle            @"dc:title"
#define kDublinCoreNature           @"dc:nature"
// Schema file
#define kXPathFileContent           @"file:content"
// Schema iPad
#define kIPadFolderTemplate         @"ipad:folder_template"
#define kIPadFolderContentDisplay   @"ipad:is_content_displayer_node"

// referential strings
#define kDocumentTypeFolder         @"Folder"
#define kDocumentTypeDocument       @"Document"

#define kNuxeoFolderTemplateValueIcons          @"icons"
#define kNuxeoFolderTemplateValueList           @"vertical_listing"

// Hierarchy names
#define kNuxeoHierarchyAllProducts              @"HierarchyAllProducts"

// Static Request

// Params for controller
#define kBrowseStandardViewControllerParamKeyPath           @"path"
#define kBrowseStandardViewControllerParamKeyColor          @"color"
#define kBrowseStandardViewControllerParamKeyLevel          @"level"

#define kNuxeoPathInitial                                   @"/"


/*!
 * You pass an NSObject* in parameter and it will be released
 * and set to nil at the same time
 * @param o	an NSObject* instance. It can be already set to nil.
 *			in which case, the macro has no effect.
 */
#define NuxeoReleaseAndNil(o) if ((o)) { [(o) release]; o = nil; }
