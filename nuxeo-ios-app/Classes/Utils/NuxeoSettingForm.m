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
                FXFormFieldTitle : NuxeoLocalized(@"settings.file.storage"),  FXFormFieldType : FXFormFieldTypeLabel, FXFormFieldFooter : @""},
              
              @{FXFormFieldKey : @"syncOverCellular",
                FXFormFieldTitle : NuxeoLocalized(@"settings.sync.cellular"),},
              
              // Authentification
              @{FXFormFieldKey : @"serverAddress",
                FXFormFieldTitle : NuxeoLocalized(@"welcome.host.url"), FXFormFieldHeader : [NuxeoLocalized(@"settings.authentication") uppercaseString]},
              
              @{FXFormFieldKey : @"username", FXFormFieldTitle : NuxeoLocalized(@"welcome.username")},
              @{FXFormFieldKey : @"password", FXFormFieldTitle : NuxeoLocalized(@"welcome.password"),
                FXFormFieldFooter : @""},

              @{FXFormFieldTitle: NuxeoLocalized(@"settings.revoke.token"),
                FXFormFieldAction: [revokeAndLogout copy]},
              ];
}

@end
