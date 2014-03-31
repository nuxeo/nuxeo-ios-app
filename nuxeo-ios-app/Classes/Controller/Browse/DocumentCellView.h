//
//  DocumentCellViewCell.h
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

#import "NuxeoLabel.h"
#import "NuxeoButton.h"

@interface DocumentCellView : UITableViewCell
{
    
}

@property (retain, nonatomic) NSIndexPath *indexPath;
@property (assign, nonatomic) id delegate;

@property (retain, nonatomic) IBOutlet UIImageView *picto;
@property (retain, nonatomic) IBOutlet NuxeoLabel *title;
@property (retain, nonatomic) IBOutlet NuxeoButton *preview;
@property (retain, nonatomic) IBOutlet NuxeoButton *openWith;
@property (retain, nonatomic) IBOutlet NuxeoButton *update;
@property (retain, nonatomic) IBOutlet NuxeoButton *addSynch;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *updateActivity;


- (IBAction)onTouchPreview:(id)sender;
- (IBAction)onTouchOpenWith:(id)sender;
- (IBAction)onTouchSync:(id)sender;
- (IBAction)onTouchInfo:(id)sender;
- (IBAction)onTouchPin:(id)sender;

- (IBAction)onTouchAddSynch:(id)sender;


- (void) setPictoBackgroundColor:(UIColor *)iColor;
- (void) setTarget:(id)target forIndexPath:(NSIndexPath *)indexPath;

- (void) updateDisplayForFile;
- (void) updateDisplayForFolder;

- (void) beginUpdate;
- (void) finishUpdate;

@end
