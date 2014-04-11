//
//  DetailDocumentInfoViewController.m
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

#import "DetailDocumentInfoViewController.h"

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXSession+requests.h>
#import <NuxeoSDK/NUXDocument.h>
#import <NuxeoSDK/NUXBlobStore.h>

@implementation DetailDocumentInfoViewController

#pragma mark -
#pragma mark PreviewDisplayViewController
#pragma mark -


#pragma mark -
#pragma mark UIViewControllerLifeCycle
#pragma mark -

/**
 * Called after the loadView call
 */
- (void)loadView
{
	[super loadView];

}

/**
 * Called after the viewDidLoad call
 */
- (void)viewDidLoad
{	
	[super viewDidLoad];
    
    
}

/**
 * Called after the viewWillAppear call
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    self.updateDate.text = [self.currentDocument.lastModified description];
    self.author.text = [self.currentDocument.properties objectForKey:@"dc:creator"];
    self.descriptionDetail.text = self.currentDocument.description;
}

/**
 * Called after the viewDidAppear call
 */
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
    
}

#pragma mark -
#pragma mark Events
#pragma mark -



- (IBAction)onTouchClose:(id)sender
{
    [self.view removeFromSuperview];
    [self release];
}


#pragma mark -
#pragma mark UIWebViewDelegate
#pragma mark -
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

#pragma mark -
#pragma mark UIViewController
#pragma mark -

#pragma mark Basics

- (void)dealloc
{
    [_currentDocument release];
    
    [_updateDate release];
    [_author release];
    [_descriptionDetail release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	NuxeoLogW(@"");
	
	[super didReceiveMemoryWarning];
	
}
@end
