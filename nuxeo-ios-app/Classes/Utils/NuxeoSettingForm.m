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

#pragma mark - Initializers -

+ (instancetype)instance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NuxeoSettingForm alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.maxStorageSize = @"1GB";
        self.syncOverCellular = YES;
        
        self.serverAddress = @"http://nuxeo.smartnsoft.com";
        self.username = @"John Appleseed";
        self.password = @"password";
    }
    return self;
}

#pragma mark - Actions -

- (void)revokeTokenAndLogout
{
    NuxeoLogD(@"Test test");
}

#pragma mark - FXForm Protocol -

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
