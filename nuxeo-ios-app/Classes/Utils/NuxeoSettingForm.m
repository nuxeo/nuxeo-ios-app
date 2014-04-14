//
//  NuxeoSettingForm.m
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 11/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import "NuxeoSettingForm.h"
#import <FXForms/FXForms.h>

#import "NuxeoSettingsManager.h"

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
        self.syncOverCellular = [[NuxeoSettingsManager instance] readBoolSetting:USER_SYNC_OVER_CELLULAR defaulValue:NO];
        
        self.serverAddress = [[NuxeoSettingsManager instance] readSetting:USER_HOST_URL defaultValue:@"http://nuxeo.smartnsoft.com"] ;
        self.username = [[NuxeoSettingsManager instance] readSetting:USER_USERNAME defaultValue:@"John Appleseed"];
        self.password = @"password";
        
        self.copyrights = NuxeoLocalized(@"nuxeo.copyrights");
    }
    return self;
}

#pragma mark - Setters -

- (void)setSyncOverCellular:(BOOL)syncOverCellular
{
    _syncOverCellular = syncOverCellular;
    [[NuxeoSettingsManager instance] saveBoolSetting:syncOverCellular forKey:USER_SYNC_OVER_CELLULAR];
}

- (void)setServerAddress:(NSString *)serverAddress
{
    if (_serverAddress == serverAddress || [_serverAddress isEqualToString:serverAddress])
        return ;
    
    NuxeoReleaseAndNil(_serverAddress);
    _serverAddress = [serverAddress retain];
    
    [[NuxeoSettingsManager instance] saveSetting:_serverAddress forKey:USER_HOST_URL];
}

- (void)setUsername:(NSString *)username
{
    if (_username == username || [_username isEqualToString:username])
        return ;

    NuxeoReleaseAndNil(_username);
    _username = [username retain];

    [[NuxeoSettingsManager instance] saveSetting:_username forKey:USER_USERNAME];
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
              @{FXFormFieldKey : @"serverAddress", FXFormFieldType : FXFormFieldTypeLabel,
                FXFormFieldTitle : NuxeoLocalized(@"welcome.host.url"), FXFormFieldHeader : [NuxeoLocalized(@"settings.authentication") uppercaseString]},
              
              @{FXFormFieldKey : @"username", FXFormFieldTitle : NuxeoLocalized(@"welcome.username"), FXFormFieldType : FXFormFieldTypeLabel},
              @{FXFormFieldKey : @"password", FXFormFieldTitle : NuxeoLocalized(@"welcome.password"),
                FXFormFieldFooter : @"", FXFormFieldType : FXFormFieldTypeLabel},

              @{FXFormFieldTitle: NuxeoLocalized(@"settings.revoke.token"),
                FXFormFieldAction: [revokeAndLogout copy], @"textLabel.color": [UIColor redColor]},
              
              @{FXFormFieldKey : @"copyrights", FXFormFieldHeader : @"", FXFormFieldType : FXFormFieldTypeDefault},
              ];
}

@end