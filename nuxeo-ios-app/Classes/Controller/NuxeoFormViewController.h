//
//  NuxeoFormViewController.h
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 11/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

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
