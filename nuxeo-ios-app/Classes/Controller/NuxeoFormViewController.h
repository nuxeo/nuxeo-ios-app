//
//  NuxeoFormViewController.h
//  nuxeo-ios-app
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
 * 	Julien Di Marco
 */

#import <UIKit/UIKit.h>
#import <FXForms/FXForms.h>

@class FXFormController;

@interface MyForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) BOOL rememberMe;

@end

@interface NuxeoFormViewController : UIViewController <FXFormControllerDelegate>
{
    IBOutlet UIView *_contentView;
    IBOutlet UIView *_titleView;
    IBOutlet UIView *_formContentView;
    
    IBOutlet UILabel *_titleLabel;
    IBOutlet UIButton *_actionButton;
    
    IBOutlet UITableView *_formTableView;
    
}

#pragma mark - Properties
@property (nonatomic, retain) FXFormController *formController;

@property (nonatomic, retain) id<FXForm> form;
@property (nonatomic, retain) NSString *formTitle;

#pragma mark - Initializers
- (id)init;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

#pragma mark - Helper

#pragma mark - Events
- (IBAction)onTapActionButton:(id)sender;


@end
