//
//  ￼NuxeoDriveRemoteServices.h
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

#define kSectionDocumentKeyOther        @"documents"
#define kSectionDocumentKeyCampaign     @"campaign_resources"

@class NUXDocument;
@class NUXHierarchy;

typedef void (^NuxeoDriveServicesBlock)(id);
typedef void (^NuxeoDriveServicesSimpleBlock)();

typedef enum NuxeoHierarchieStatus
{
	NuxeoHierarchieStatusNotLoaded = 0,
    NuxeoHierarchieStatusLoaded = 1,
    NuxeoHierarchieStatusBinariesLoaded = 2
} NuxeoHierarchieStatus;

@interface NuxeoDriveRemoteServices : NSObject
{
    NSMutableDictionary * synchronisedPoints;
}

@property (nonatomic, readonly) NSDictionary * synchronisedPoints;

+ (NuxeoDriveRemoteServices *) instance;

- (NSString *) getIOSLanguage;

// Retrieve Hierarchy for suite
- (NSArray *) retrieveAllDocumentsOfHierarchy:(NSString *)iHierarchyName;
- (NUXHierarchy *) getHierarchyWithName:(NSString *)iHerarchieName;
- (void) loadBinariesOfHierarchy:(NSString *)iHerarchieName completionBlock:(NuxeoDriveServicesBlock)completion;
- (NuxeoHierarchieStatus) getHierarchyStatus:(NSString *)hierarchieName;

// Methods for Nuxeo Drive synchronize points
- (void) retrieveAllSynchronizePoints:(NuxeoDriveServicesBlock)completion;
- (void) addSynchronizePoint:(NSString *)iPath completionBlock:(NuxeoDriveServicesBlock)completion;
- (void) removeSynchronizePoint:(NSString *)iPath completionBlock:(NuxeoDriveServicesBlock)completion;
- (void) refreshAllSyncPoints;

// Blob methods
- (NSString *) getDocPathForDocument:(NUXDocument *)nuxDocument;


@end
