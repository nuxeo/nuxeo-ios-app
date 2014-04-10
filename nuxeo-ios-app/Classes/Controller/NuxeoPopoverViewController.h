//
//  NuxeoPopoverViewController.h
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 10/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NuxeoActionPopoverDelegate;

@interface NuxeoPopoverViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *_tableview;
    
    NSArray *_stringArray;
}

#pragma mark - Properties
@property (nonatomic, assign) id<NuxeoActionPopoverDelegate> delegate;
@property (nonatomic, assign) UIPopoverController *parentPopover;

#pragma mark - Initializers
- (id)init;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end

@protocol NuxeoActionPopoverDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionPopover:(UIPopoverController *)popover clickedButtonAtIndex:(NSInteger)buttonIndex;

@end