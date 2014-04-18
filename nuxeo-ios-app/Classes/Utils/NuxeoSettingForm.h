//
//  NuxeoSettingForm.h
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 11/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>

@class TTTUnitOfInformationFormatter;

@interface FXFormTextSliderCell : FXFormBaseCell
{
    TTTUnitOfInformationFormatter *_unitOfInformationFormatter;
}

@property (nonatomic, retain) UISlider *slider;
@end

@interface NuxeoSettingForm : NSObject <FXForm>
{
    TTTUnitOfInformationFormatter *_unitOfInformationFormatter;
}

@property (nonatomic, retain) NSString  *maxStorageSize;
@property (nonatomic, retain) NSNumber  *limitStorageSize;

@property (nonatomic, assign) BOOL      syncOverCellular;

@property (nonatomic, retain) NSString  *serverAddress;
@property (nonatomic, retain) NSString  *username;
@property (nonatomic, retain) NSString  *password;

@property (nonatomic, retain) NSString  *copyrights;

#pragma mark - Initializers
+ (instancetype)instance;

#pragma mark - Test
- (void)revokeTokenAndLogout;

@end
