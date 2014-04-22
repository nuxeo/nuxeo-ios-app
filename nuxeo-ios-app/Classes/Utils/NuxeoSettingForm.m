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
#import "NuxeoDriveRemoteServices.h"
#import "WelcomeViewController.h"

@interface FXFormBaseCell ()
- (void)setUp;
- (void)update;
@end

@implementation FXFormTextSliderCell

- (void)setUp
{
    [super setUp];
    
    _unitOfInformationFormatter = [[TTTUnitOfInformationFormatter alloc] init];
    _unitOfInformationFormatter.numberFormatter.roundingIncrement = @(1.f);
    _unitOfInformationFormatter.numberFormatter.roundingMode = NSNumberFormatterRoundCeiling;
    _unitOfInformationFormatter.displaysInTermsOfBytes = NO;
    _unitOfInformationFormatter.usesIECBinaryPrefixesForCalculation = NO;
    
    self.slider = [[UISlider alloc] init];
    [self.slider addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.slider];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect sliderFrame = self.slider.frame;
    
    self.textLabel.frame = (CGRect){CGRectGetMinX(self.textLabel.frame), 12, self.textLabel.frame.size};
    self.detailTextLabel.frame = (CGRect){CGRectGetMinX(self.detailTextLabel.frame), 12, self.detailTextLabel.frame.size};
    
    sliderFrame.origin.x = 10;
    sliderFrame.origin.y = CGRectGetMaxY(self.textLabel.frame) + 12;
    sliderFrame.size.width = self.contentView.bounds.size.width - sliderFrame.origin.x - 10;

    self.slider.frame = sliderFrame;
}

- (void)update
{
    [super update];
    
    self.textLabel.text = self.field.title;
    self.detailTextLabel.text = [_unitOfInformationFormatter stringFromNumberOfBits:self.field.value];;
    self.slider.value = [self.field.value doubleValue];
    
    [self setNeedsLayout];
}

- (void)valueChanged
{
    self.field.value = @(self.slider.value);
    self.detailTextLabel.text = [_unitOfInformationFormatter stringFromNumberOfBits:self.field.value];;
    if (self.field.action) self.field.action(self);
}

+ (CGFloat)heightForField:(FXFormField *)field
{
    return 68 + 10;
}

- (void)dealloc
{
    NuxeoReleaseAndNil(_unitOfInformationFormatter);
    
    self.slider = nil;
    [super dealloc];
}

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
        _unitOfInformationFormatter = [[TTTUnitOfInformationFormatter alloc] init];
        _unitOfInformationFormatter.numberFormatter.roundingIncrement = @(0.1f);
        _unitOfInformationFormatter.displaysInTermsOfBytes = NO;
        _unitOfInformationFormatter.usesIECBinaryPrefixesForCalculation = NO;
        
        self.limitStorageSize = [[NuxeoSettingsManager instance] readSetting:USER_FILES_STORE_MAX_SIZE defaultValue:@(5.0f * kGigabyteSize)];
        self.maxStorageSize = [_unitOfInformationFormatter stringFromNumberOfBits:self.limitStorageSize];
        
        self.syncOverCellular = [[NuxeoSettingsManager instance] readBoolSetting:USER_SYNC_OVER_CELLULAR defaulValue:NO];
        
        self.serverAddress = [[NuxeoSettingsManager instance] readSetting:USER_HOST_URL defaultValue:@"http://demo.nuxeo.com/nuxeo/"] ;
        self.username = [[NuxeoSettingsManager instance] readSetting:USER_USERNAME defaultValue:@"John Doe"];
        self.password = @"password";
        
        NSString * masterVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        self.copyrights = [NSString stringWithFormat:NuxeoLocalized(@"nuxeo.copyrights"), masterVersion];
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

- (void)setLimitStorageSize:(NSNumber *)limitStorageSize
{
    if (_limitStorageSize == limitStorageSize || [_limitStorageSize isEqualToNumber:limitStorageSize])
        return ;

    NuxeoReleaseAndNil(_limitStorageSize);
    _limitStorageSize = [[NSNumber numberWithFloat:ceilf([limitStorageSize floatValue])] retain];
    
    if (!_limitStorageSize)
        return ;
    
    [[NuxeoSettingsManager instance] saveSetting:_limitStorageSize forKey:USER_FILES_STORE_MAX_SIZE];
    self.maxStorageSize = [_unitOfInformationFormatter stringFromNumberOfBits:_limitStorageSize];
    
    NuxeoLogD(@"maxStorage Modified: %@ --> %@", _limitStorageSize, [_unitOfInformationFormatter stringFromNumberOfBits:_limitStorageSize]);
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFxForm" object:self userInfo:@{@"form" : self}];
}

#pragma mark - Actions -

- (void)revokeTokenAndLogout
{
    NUXSession * nuxSession = [NUXSession sharedSession];
    if (nuxSession.authenticator != nil)
    {
        [[NuxeoDriveRemoteServices instance] resetSynchronizedPoints];
        [((NUXTokenAuthenticator *)nuxSession.authenticator) resetSettings];
        nuxSession.authenticator = nil;
        [[APP_DELEGATE getVisibleViewController] dismissViewControllerAnimated:NO completion:NULL];
    }
}

#pragma mark - Helper cracra - 

+ (CGFloat)totalDiskSpaceInBytes
{
    return [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
}

+ (CGFloat)freeDiskSpaceInBytes
{
    return [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
}

+ (CGFloat)usedDiskSpaceInBytes
{
    return [self totalDiskSpaceInBytes] - [self freeDiskSpaceInBytes];
}

#pragma mark - FXForm Protocol -

- (NSArray *)fields
{
    NuxeoSettingForm * __block weakSelf = self;
    
    void (^revokeAndLogout)(id sender) = ^(id _) {
        [weakSelf revokeTokenAndLogout];
    };
    
    return  @[
//              @{FXFormFieldKey : @"maxStorageSize",
//                FXFormFieldTitle : NuxeoLocalized(@"settings.file.storage"), FXFormFieldType : FXFormFieldTypeLabel},
              
              @{FXFormFieldKey : @"limitStorageSize", FXFormFieldTitle: NuxeoLocalized(@"settings.file.storage"),
                FXFormFieldCell : [FXFormTextSliderCell class], FXFormFieldFooter : @"",
                @"slider.minimumValue" : @(1.0f * kMegabyteSize), @"slider.maximumValue" : @([NuxeoSettingForm totalDiskSpaceInBytes])},
              
              @{FXFormFieldKey : @"syncOverCellular",
                FXFormFieldTitle : NuxeoLocalized(@"settings.sync.cellular"),},
              
              // Authentification
              @{FXFormFieldKey : @"serverAddress", FXFormFieldType : FXFormFieldTypeLabel,
                FXFormFieldTitle : NuxeoLocalized(@"welcome.host.url"), FXFormFieldHeader : [NuxeoLocalized(@"settings.authentication") uppercaseString]},
              
              @{FXFormFieldKey : @"username", FXFormFieldTitle : NuxeoLocalized(@"welcome.username"), FXFormFieldType : FXFormFieldTypeLabel},
              @{FXFormFieldKey : @"password", FXFormFieldTitle : NuxeoLocalized(@"welcome.password"),
                FXFormFieldFooter : @"", @"textField.enabled" : @(NO)},

              @{FXFormFieldTitle: NuxeoLocalized(@"settings.revoke.token"),
                FXFormFieldAction: [revokeAndLogout copy], @"textLabel.color": [UIColor redColor]},
              
              @{FXFormFieldKey : @"copyrights", FXFormFieldHeader : @"", FXFormFieldType : FXFormFieldTypeDefault},
              ];
}

#pragma mark - Memory Management -

- (void)dealloc
{
    NuxeoReleaseAndNil(_unitOfInformationFormatter);
    
    self.maxStorageSize = nil;
    self.limitStorageSize = nil;
    
    self.serverAddress = nil;
    self.username = nil;
    self.password = nil;
    
    self.copyrights = nil;
    
    [super dealloc];
}

@end
