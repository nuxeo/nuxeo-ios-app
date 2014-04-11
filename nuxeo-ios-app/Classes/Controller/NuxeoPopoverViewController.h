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
}

#pragma mark - Properties
@property (nonatomic, assign) id<NuxeoActionPopoverDelegate> delegate;

@property (nonatomic, assign) UIPopoverController *parentPopover;
@property (nonatomic, assign) id caller;

@property (nonatomic, retain) NSArray *titles;

#pragma mark - Initializers
- (id)init;
- (id)initWithTitles:(NSArray *)titles;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end

@protocol NuxeoActionPopoverDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionPopoverCaller:(id)caller clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)actionPopover:(UIPopoverController *)popover clickedButtonAtIndex:(NSInteger)buttonIndex;

@end