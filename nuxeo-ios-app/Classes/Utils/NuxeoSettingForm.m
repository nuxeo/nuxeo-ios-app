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
    void (^revokeAndLogout)(void) = ^{
        [self revokeTokenAndLogout];
    };
    
    return  @[
              
              @{FXFormFieldKey : @"maxStorageSize",
                FXFormFieldTitle : @"Files storage max size",  FXFormFieldType : FXFormFieldTypeLabel},
              
              @{FXFormFieldKey : @"syncOverCellular",
                FXFormFieldTitle : @"Sync over cellular"},
              
              // Authentification
              @{FXFormFieldKey : @"serverAddress",
                FXFormFieldTitle : @"0", FXFormFieldHeader : [@"Authentification" uppercaseString]},
              
              @{FXFormFieldKey : @"username", FXFormFieldTitle : @"1"},
              @{FXFormFieldKey : @"password", FXFormFieldTitle : @"2"},

              @{FXFormFieldTitle: @"Revoke token and Log out",
                FXFormFieldHeader: @"", FXFormFieldAction: [revokeAndLogout copy]},
              ];
}

@end
