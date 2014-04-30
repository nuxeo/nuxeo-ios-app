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

#import "NuxeoSettingsManager.h"

@implementation PreviewDisplayViewController

#pragma mark -
#pragma mark PreviewDisplayViewController
#pragma mark -

- (void) addHeaderButtonBar:(UIView *) navBarCustomView
{
    self.headerBar.frame = (CGRect){CGPointMake(NuxeoViewW(navBarCustomView) - NuxeoViewW(self.headerBar), NuxeoViewY(self.headerBar)) , self.headerBar.frame.size};
    
    [navBarCustomView addSubview:self.headerBar];
}

- (void) loadDocument:(NSData*)docData
{
    [self.openWithButton setEnabled:YES];
    
    [self.previewView loadData:docData MIMEType:self.mimeType textEncodingName:@"utf-8" baseURL:nil];
    self.previewView.hidden = NO;
}

- (void) loadDocumentByPath:(NSString*)docPath
{
    [self.openWithButton setEnabled:YES];
        
    NSURL *url = [NSURL fileURLWithPath:docPath];
    if ([self.mimeType rangeOfString:@"video"].location != NSNotFound)
    {
        if (_videoAlreadyPlayed == NO)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _videoAlreadyPlayed = YES;
                moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
                
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDonePressed:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDonePressed:) name:MPMoviePlayerDidExitFullscreenNotification object:moviePlayer];
                
                moviePlayer.controlStyle = MPMovieControlStyleDefault;
                moviePlayer.movieSourceType = MPMovieSourceTypeFile;
                moviePlayer.shouldAutoplay = YES;
                [moviePlayer play];
                [self.view addSubview:moviePlayer.view];
                [moviePlayer setFullscreen:YES animated:YES];
            });
        }
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
    NuxeoReleaseAndNil(moviePlayer);
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void) previewDocument
{
    [self.loadingIndicator stopAnimating];
    NSString * blobPath = [[NUXBlobStore instance] blobFromDocument:self.currentDocument metadataXPath:kXPathFileContent];
    
    if ([self.mimeType rangeOfString:@"video"].location != NSNotFound && self.mimeType != nil)
    {
        [self loadDocumentByPath:blobPath];
    }
    else
    {
        if (blobPath != nil)
        {
            NSData * docData = [NSData dataWithContentsOfFile:blobPath];
            [self loadDocument:docData];
        }
    }
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
	
    [self.openWithButton setEnabled:NO];
    
    self.previewView.delegate = self;

}

/**
 * Called after the viewDidLoad call
 */
- (void)viewDidLoad
{	
	[super viewDidLoad];
    
    _videoAlreadyPlayed = NO;
    
    // update header button position
    if ([self.context isEqualToString:kBrowseDocumentOnLine])
    {
        self.update.hidden = YES;
    }
        
    [self.loadingIndicator startAnimating];
    
    if ([self.currentDocument hasBinaryFile] == YES)
    {
        self.mimeType = [[self.currentDocument.properties objectForKey:kXPathFileContent] objectForKey:@"mime-type"];
    }
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
    
    if([self.currentDocument hasBinaryFileOnDevice] == YES)
    {
        [self previewDocument];
    }
    else
    {
        if ([APP_DELEGATE isNetworkConnected] == YES)
        {
            [self onTouchUpdate:nil];
        }
        else
        {
            [UIAlertView showWithTitle:NuxeoLocalized(@"application.name")
                               message:NuxeoLocalized(@"application.notconnected")
                     cancelButtonTitle:NuxeoLocalized(@"button.ok")
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  // Go back
                                  [self dismissViewControllerAnimated:YES completion:NULL];
                              }];
        }
    }
}

#pragma mark -
#pragma mark Events
#pragma mark -


- (void)onTouchOpenWith:(id)sender
{
    NSString * blobPath = [[NUXBlobStore instance] blobFromDocument:self.currentDocument metadataXPath:kXPathFileContent];
    
    [self openWithShow:blobPath mimeType:self.mimeType fromView:(UIView *)sender];
}

- (IBAction)onTouchPin:(id)sender
{

}

- (IBAction)onTouchInfo:(id)sender
{
  [CONTROLLER_HANDLER pushDetailDocumentInfoControllerFrom:self options:@{kParamKeyDocument : self.currentDocument}];
}

- (IBAction)onTouchUpdate:(id)sender
{
    // Load binary to show it in preview webview
    [self.loadingIndicator startAnimating];
    NUXSession * nuxSession = [NUXSession sharedSession];
    NUXRequest *request = [nuxSession requestDownloadBlobFrom:self.currentDocument.uid
                                                   inMetadata:kXPathFileContent];
    NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tempfile%d.tmp", arc4random()]];
    request = [nuxSession requestDownloadBlobFrom:self.currentDocument.uid inMetadata:kXPathFileContent];
    request.downloadDestinationPath = tempFile;
    [request setCompletionBlock:^(NUXRequest *request) {
        [[NUXBlobStore instance] saveBlobFromPath:tempFile withDocument:self.currentDocument metadataXPath:kXPathFileContent error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
        
        [self.openWithButton setEnabled:YES];
        
        [self previewDocument];
    }];
    
    [request start];
}

#pragma mark -
#pragma mark UIWebViewDelegate
#pragma mark -
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingIndicator stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NuxeoLogD(@"webView error : %@", [error description]);
    if (_fallbackURLContent == nil && [APP_DELEGATE isNetworkConnected] == YES)
    {
        [self.loadingIndicator startAnimating];
        NSString * hostUrl = [[NuxeoSettingsManager instance] readSetting:USER_HOST_URL defaultValue:kNuxeoSiteURL];
        NSString * newUrl = [NSString stringWithFormat:@"%@/nxfile/default/%@/blobholder:0/temp.html", hostUrl, self.currentDocument.uid];
        _fallbackURLContent = [NSURL URLWithString:newUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:_fallbackURLContent];
        [self.previewView loadRequest:request];
    }
    else
    {
        self.previewError.hidden = NO;
    }
}

#pragma mark -
#pragma mark UIViewController
#pragma mark -

#pragma mark Basics

- (void)dealloc
{
    [_mimeType release];
    [_currentDocument release];
    [_context release];
    
    self.docController = nil;
    self.openWithButton = nil;
    
    [moviePlayer release];
    moviePlayer = nil;
    
    [_previewView release];
    [_headerBar release];
    [_openWithButton release];
    [_loadingIndicator release];
    [_previewError release];
    [_update release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	NuxeoLogW(@"");
	
	[super didReceiveMemoryWarning];
	
}

@end
