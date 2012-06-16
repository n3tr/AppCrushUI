//
//  DragDropImageView.h
//  AppCrushUI
//
//  Created by Jirat Kijlerdpornpailoj on 6/16/55 BE.
//  Copyright (c) 2555 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

@interface DragDropImageView : NSImageView <NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>

@property (assign) BOOL highlight;

@end
