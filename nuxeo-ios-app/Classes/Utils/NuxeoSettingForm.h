//
//  NuxeoSettingForm.h
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 11/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>

@interface NuxeoSettingForm : NSObject <FXForm>

@property (nonatomic, retain) NSString  *maxStorageSize;
@property (nonatomic, assign) BOOL      syncOverCellular;

@property (nonatomic, retain) NSURL     *serverAddress;
@property (nonatomic, retain) NSString  *username;
@property (nonatomic, retain) NSString  *password;

#pragma mark - Test
- (void)revokeTokenAndLogout;

@end
