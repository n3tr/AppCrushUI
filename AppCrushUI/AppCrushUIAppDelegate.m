//
//  AppCrushUIAppDelegate.m
//  AppCrushUI
//
//  Created by Jirat Kijlerdpornpailoj on 6/16/55 BE.
//  Copyright (c) 2555 __MyCompanyName__. All rights reserved.
//

#import "AppCrushUIAppDelegate.h"

@implementation AppCrushUIAppDelegate

@synthesize window = _window;
@synthesize loadingView = _loadingView;
@synthesize progressView = _progressView;
@synthesize progressLabel = _progressLabel;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [_progressView setHidden:YES];
    [_loadingView setHidden:YES];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)showLoadingView:(BOOL)flag
{
    if (flag) {
        [_loadingView setHidden:NO];
        [_progressView setHidden:NO];
        [_progressView startAnimation:self];
    }else {
        [_loadingView setHidden:YES];
        [_progressView setHidden:NO];
        [_progressView stopAnimation:self];
    }
}




@end
