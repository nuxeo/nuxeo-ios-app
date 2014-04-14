//
//  NuxeoPopoverViewController.h
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