//
//  PreviewDisplayViewController.m
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

#import "PreviewDisplayViewController.h"

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXSession+requests.h>
#import <NuxeoSDK/NUXDocument.h>
#import <NuxeoSDK/NUXBlobStore.h>

#import "NuxeoDriveRemoteServices.h"

#import "NuxeoButton.h"

#import "NuxeoDriveUtils.h"

@implementation PreviewDisplayViewController

#pragma mark -
#pragma mark PreviewDisplayViewController
#pragma mark -

- (void) addHeaderButtonBar:(UIView *) navBarCustomView
{
    // Sync document
    NuxeoButton * syncButton = [NuxeoButton buttonWithType:UIButtonTypeCustom];
    syncButton.frame = CGRectMake(880,20,120,40);
    [syncButton setBackgroundColor:[UIColor blackColor]];
    [syncButton setTitle:NuxeoLocalized(@"button.sync") forState:UIControlStateNormal];
    [syncButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [syncButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [syncButton setBackgroundImage:[UIImage imageNamed:@"bt_update"] forState:UIControlStateNormal];
    [syncButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    syncButton.titleLabel.font = FONT_COMMON_BOLD(15);
    [navBarCustomView addSubview:syncButton];
    [syncButton addTarget:self action:@selector(onTouchSyncDoc:) forControlEvents:UIControlEventTouchUpInside];
    
    // OpenWith button
    self.openwithButton = [NuxeoButton buttonWithType:UIButtonTypeCustom];
    self.openwithButton.frame = CGRectMake(670,20,160,40);
    [self.openwithButton setBackgroundColor:[UIColor blackColor]];
    [self.openwithButton setTitle:NuxeoLocalized(@"button.openwith") forState:UIControlStateNormal];
    [self.openwithButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.openwithButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.openwithButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage * openWithImage = [[UIImage imageNamed:@"bt_open_with"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 50, 0, 0) resizingMode:UIImageResizingModeTile];
    [self.openwithButton setBackgroundImage:openWithImage forState:UIControlStateNormal];
    [self.openwithButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
    self.openwithButton.titleLabel.font = FONT_COMMON_BOLD(15);
    [navBarCustomView addSubview:self.openwithButton];
    [self.openwithButton addTarget:self action:@selector(onTouchOpenWith:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateDisplay
{
	
}

- (void) loadDocument:(NSData*)docData
{
    [self.openwithButton setEnabled:YES];
    
    [self.previewView loadData:docData MIMEType:self.mimeType textEncodingName:@"utf-8" baseURL:nil];
    self.previewView.hidden = NO;
}

- (void) loadDocumentByPath:(NSString*)docPath
{
    [self.openwithButton setEnabled:YES];
    
    
    NSURL *url = [NSURL fileURLWithPath:docPath];
    if ([self.mimeType rangeOfString:@"video"].location != NSNotFound)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
            
            // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDonePressed:) name:MPMoviePlayerDidExitFullscreenNotification object:moviePlayer];
            
            moviePlayer.controlStyle = MPMovieControlStyleDefault;
            moviePlayer.movieSourceType = MPMovieSourceTypeFile;
            moviePlayer.shouldAutoplay = YES;
            [moviePlayer play];
            [self.view addSubview:moviePlayer.view];
            [moviePlayer setFullscreen:YES animated:YES];
        });
        
    }
    else if([self.mimeType rangeOfString:@"image"].location != NSNotFound)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.previewView loadRequest:request];
        self.previewView.hidden = NO;
    }
    else
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.previewView loadRequest:request];
        self.previewView.hidden = NO;
    }
    
}

- (void) moviePlayBackDonePressed:(NSNotification*)notification
{
    [moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:moviePlayer];
    
    
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [moviePlayer.view removeFromSuperview];
    }
    //moviePlayer=nil;
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -
#pragma mark UIViewControllerLifeCycle
#pragma mark -

/**
 * Called after the loadView call
 */
- (void)loadView
{
	[super loadView];
	
    [self.openwithButton setEnabled:NO];
    
    self.previewView.delegate = self;

}

/**
 * Called after the viewDidLoad call
 */
- (void)viewDidLoad
{	
	[super viewDidLoad];
    
    self.mimeType = [[self.currentDocument.properties objectForKey:kXPathFileContent] objectForKey:@"mime-type"];
}

/**
 * Called after the viewWillAppear call
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

/**
 * Called after the viewDidAppear call
 */
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
    if([[NUXBlobStore instance] hasBlobFromDocument:self.currentDocument metadataXPath:kXPathFileContent] == YES)
    {
        NSString * blobPath = [[NUXBlobStore instance] blobFromDocument:self.currentDocument metadataXPath:kXPathFileContent];
        
        if ([self.mimeType rangeOfString:@"video"].location != NSNotFound)
        {
            [self loadDocumentByPath:blobPath];
        }
        else
        {
            NSData * docData = [NSData dataWithContentsOfFile:blobPath];
            [self loadDocument:docData];
        }
    }
}

#pragma mark -
#pragma mark Events
#pragma mark -


- (void)onTouchOpenWith:(id)sender
{
    NSString * docLocalPath = [[NuxeoDriveRemoteServices instance] getDocPathForDocument:self.currentDocument];
    [self openWithShow:docLocalPath mimeType:self.mimeType fromView:(UIView *)sender];
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
    [_previewView release];
    [_mimeType release];
    [_currentDocument release];
    
    self.docController = nil;
    self.openwithButton = nil;
    
    [moviePlayer release];
    moviePlayer = nil;
    
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	NuxeoLogW(@"");
	
	[super didReceiveMemoryWarning];
	
}

@end
