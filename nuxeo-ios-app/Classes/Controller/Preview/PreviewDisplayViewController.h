//
//  PreviewDisplayViewController.h
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
#import <MediaPlayer/MediaPlayer.h>

#import "NuxeoDriveViewController.h"

#import "NuxeoButton.h"

@class NUXDocument;

@interface PreviewDisplayViewController : NuxeoDriveViewController<UIWebViewDelegate>
{
    MPMoviePlayerController * moviePlayer;
}


@property (retain, nonatomic) IBOutlet UIView *headerBar;
@property (retain, nonatomic) IBOutlet NuxeoButton *update;
@property (retain, nonatomic) IBOutlet UIWebView *previewView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet NuxeoButton *openWithButton;
@property (retain, nonatomic) IBOutlet UIView *previewError;

@property (retain, nonatomic) NSString * context;
@property (retain, nonatomic) NSString * mimeType;
@property (retain, nonatomic) NUXDocument * currentDocument;

- (IBAction)onTouchOpenWith:(id)sender;
- (IBAction)onTouchPin:(id)sender;
- (IBAction)onTouchInfo:(id)sender;
- (IBAction)onTouchUpdate:(id)sender;

@end
