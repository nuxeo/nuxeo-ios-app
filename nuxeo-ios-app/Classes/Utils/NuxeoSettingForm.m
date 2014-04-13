//
//  NuxeoSettingForm.m
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 11/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import "NuxeoSettingForm.h"
#import <FXForms/FXForms.h>

@implementation NuxeoSettingForm

- (void)revokeTokenAndLogout
{
    NuxeoLogD(@"Test test");
}

- (NSArray *)fields
{
    NuxeoSettingForm * __block weakSelf = self;
    
    void (^revokeAndLogout)(void) = ^{
        [weakSelf revokeTokenAndLogout];
    };
    
    return  @[
              
              @{FXFormFieldKey : @"maxStorageSize",
                FXFormFieldTitle : @"Files storage max size",  FXFormFieldType : FXFormFieldTypeLabel, FXFormFieldFooter : @""},
              
              @{FXFormFieldKey : @"syncOverCellular",
                FXFormFieldTitle : @"Sync over cellular",},
              
              // Authentification
              @{FXFormFieldKey : @"serverAddress",
                FXFormFieldTitle : @"0", FXFormFieldHeader : [@"Authentification" uppercaseString]},
              
              @{FXFormFieldKey : @"username", FXFormFieldTitle : @"1"},
              @{FXFormFieldKey : @"password", FXFormFieldTitle : @"2",
                FXFormFieldFooter : @""},

              @{FXFormFieldTitle: @"Revoke token and Log out",
                FXFormFieldAction: [revokeAndLogout copy]},
              ];
}

@end
