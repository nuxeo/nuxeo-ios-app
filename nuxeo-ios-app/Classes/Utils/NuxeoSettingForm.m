//
//  NuxeoSettingForm.m
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 11/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXTokenAuthenticator.h>

#import <FXForms/FXForms.h>
#import <FormatterKit/TTTUnitOfInformationFormatter.h>

#import "NuxeoSettingForm.h"

#import "NuxeoSettingsManager.h"
#import "WelcomeViewController.h"

@interface NuxeoSettingForm ()

@property (nonatomic, retain) NSNumber *limitStorageSize;

@end

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
        self.limitStorageSize = [[NuxeoSettingsManager instance] readSetting:USER_FILES_STORE_MAX_SIZE defaultValue:@(5.0f * kGigabyteSize)];
        
        _unitOfInformationFormatter = [[TTTUnitOfInformationFormatter alloc] init];
        _unitOfInformationFormatter.numberFormatter.roundingIncrement = @(0.1f);
        [_unitOfInformationFormatter setDisplaysInTermsOfBytes:NO];
        [_unitOfInformationFormatter setUsesIECBinaryPrefixesForCalculation:NO];
        
        self.maxStorageSize = [_unitOfInformationFormatter stringFromNumberOfBits:self.limitStorageSize];
        self.syncOverCellular = [[NuxeoSettingsManager instance] readBoolSetting:USER_SYNC_OVER_CELLULAR defaulValue:NO];
        
        self.serverAddress = [[NuxeoSettingsManager instance] readSetting:USER_HOST_URL defaultValue:@"http://demo.nuxeo.com/nuxeo/"] ;
        self.username = [[NuxeoSettingsManager instance] readSetting:USER_USERNAME defaultValue:@"John Doe"];
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
    NUXSession * nuxSession = [NUXSession sharedSession];
    if (nuxSession.authenticator != nil)
    {
        [((NUXTokenAuthenticator *)nuxSession.authenticator) resetSettings];
        [[APP_DELEGATE getVisibleViewController] dismissViewControllerAnimated:NO completion:NULL];
    }
}

- (void)storageSizeValueChanged:(FXFormSliderCell *)sender
{
    self.limitStorageSize = @(sender.slider.value);
    
    [[NuxeoSettingsManager instance] saveSetting:self.limitStorageSize forKey:USER_FILES_STORE_MAX_SIZE];
    self.maxStorageSize = [_unitOfInformationFormatter stringFromNumberOfBits:self.limitStorageSize];

    NuxeoLogD(@"maxStorage Modified: %f --> %@", sender.slider.value, [_unitOfInformationFormatter stringFromNumberOfBits:@(sender.slider.value)]);

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFxForm" object:self userInfo:@{ @"form" : self }];
}

#pragma mark - FXForm Protocol -

- (NSArray *)fields
{
    NuxeoSettingForm * __block weakSelf = self;
    
    void (^revokeAndLogout)(id sender) = ^(id _) {
        [weakSelf revokeTokenAndLogout];
    };
    
    void (^storageSizeValueChanged)(id sender) = ^(id sender) {
        [weakSelf storageSizeValueChanged:sender];
    };
    
    return  @[
              
              @{FXFormFieldKey : @"maxStorageSize",
                FXFormFieldTitle : NuxeoLocalized(@"settings.file.storage"), FXFormFieldType : FXFormFieldTypeLabel},
              
              @{FXFormFieldTitle: @"",
                FXFormFieldCell : [FXFormSliderCell class], FXFormFieldAction : [storageSizeValueChanged copy], FXFormFieldFooter : @"",
                @"slider.minimumValue" : @(1.0f * kMegabyteSize), @"slider.maximumValue" : @(10 * kGigabyteSize), @"slider.value" : self.limitStorageSize},
              
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
