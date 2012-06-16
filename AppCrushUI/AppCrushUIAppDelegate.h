//
//  AppCrushUIAppDelegate.h
//  AppCrushUI
//
//  Created by Jirat Kijlerdpornpailoj on 6/16/55 BE.
//  Copyright (c) 2555 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

@interface AppCrushUIAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSView *loadingView;

@property (weak) IBOutlet NSProgressIndicator *progressView;
@property (weak) IBOutlet NSTextField *progressLabel;

- (void)showLoadingView:(BOOL)flag;

@end
