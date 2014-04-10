//
//  NuxeoDriveViewController.m
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

#import <UIKit/UIKit.h>

#import "NuxeoDriveControllerHandler.h"

@class NUXDocument;

extern NSString* const kMainBackgroundResourceName;
extern NSString* const kBackButtonResourceName;

#pragma mark - NuxeoDriveViewController
@interface NuxeoDriveViewController : UIViewController <UIDocumentInteractionControllerDelegate, UIAlertViewDelegate>
{
	UIView *_navBarCustomView;
    UIView *_footerBarCustomView;
}

#pragma mark - Properties
@property (nonatomic, getter = isHeaderHidden)         BOOL headerHidden;
@property (nonatomic, getter = isFooterHidden)         BOOL footerHidden;
@property (nonatomic, getter = isBackButtonShown)      BOOL backButtonShown;
@property (nonatomic, getter = isUpdateAllButtonShown) BOOL updateAllButtonShown;

@property (nonatomic, getter = isAbstractView) BOOL abstractView;

// Header
@property (retain, nonatomic) UIButton * pinButton;
@property (retain, nonatomic) UIButton * searchButton;
@property (retain, nonatomic) UIButton * updateAllButton;
@property (retain, nonatomic) UIButton * settingsButton;

@property (retain, nonatomic) UIDocumentInteractionController * docController;

#pragma mark - Initializers

- (instancetype)init;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

#pragma mark - generic messages
- (void) checkAuthentication;
- (void) retrieveBusinessObjects;
- (void) synchronizeAllView;

- (UIView *) headerBarView;
- (UIView *) footerBarView;
- (UIView *) backgroundView;

- (void) logout;

#pragma mark - Helpers messages

// Header button bar (override it to set a custom button bar)
- (void) addHeaderButtonBar:(UIView *) navBarCustomView;
- (void) openWithShow:(NSString *)docPath mimeType:(NSString *)mimeType fromView:(UIView *)iView;

@end
