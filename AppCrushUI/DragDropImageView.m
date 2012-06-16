//
//  DragDropImageView.m
//  AppCrushUI
//
//  Created by Jirat Kijlerdpornpailoj on 6/16/55 BE.
//  Copyright (c) 2555 __MyCompanyName__. All rights reserved.
//

#import "DragDropImageView.h"


@implementation DragDropImageView

@synthesize highlight;

NSString *kPrivateDragUTI = @"com.simpletail.cocoadraganddrop";

- (id)initWithCoder:(NSCoder *)coder
{
    /*------------------------------------------------------
     Init method called for Interface Builder objects
     --------------------------------------------------------*/
    self=[super initWithCoder:coder];
    if ( self ) {
        //register for all the image types we can display
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    return self;
}

#pragma mark - Destination Operations

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method called whenever a drag enters our drop zone
     --------------------------------------------------------*/
    
    highlight=YES;
    [self setNeedsDisplay: YES];
    return NSDragOperationLink;
     
    
    // Check if the pasteboard contains image data and source/user wants it copied
    if ( [NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
        [sender draggingSourceOperationMask] &
        NSDragOperationCopy ) {
        
        //highlight our drop zone
        highlight=YES;
        
        [self setNeedsDisplay: YES];
        
        /* When an image from one window is dragged over another, we want to resize the dragging item to
         * preview the size of the image as it would appear if the user dropped it in. */
        [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent 
                                          forView:self
                                          classes:[NSArray arrayWithObject:[NSPasteboardItem class]] 
                                    searchOptions:nil 
                                       usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
                                           
                                           /* Only resize a fragging item if it originated from one of our windows.  To do this,
                                            * we declare a custom UTI that will only be assigned to dragging items we created.  Here
                                            * we check if the dragging item can represent our custom UTI.  If it can't we stop. */
                                           if ( ![[[draggingItem item] types] containsObject:kPrivateDragUTI] ) {
                                               
                                               *stop = YES;
                                               
                                           } else {
                                               /* In order for the dragging item to actually resize, we have to reset its contents.
                                                * The frame is going to be the destination view's bounds.  (Coordinates are local 
                                                * to the destination view here).
                                                * For the contents, we'll grab the old contents and use those again.  If you wanted
                                                * to perform other modifications in addition to the resize you could do that here. */
                                               [draggingItem setDraggingFrame:self.bounds contents:[[[draggingItem imageComponents] objectAtIndex:0] contents]];
                                           }
                                       }];
        
        //accept data as a copy operation
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method called whenever a drag exits our drop zone
     --------------------------------------------------------*/
    //remove highlight of the drop zone
    highlight=NO;
    
    [self setNeedsDisplay: YES];
}

-(void)drawRect:(NSRect)rect
{
    /*------------------------------------------------------
     draw method is overridden to do drop highlighing
     --------------------------------------------------------*/
    //do the usual draw operation to display the image
    [super drawRect:rect];
    
    if ( highlight ) {
        //highlight by overlaying a gray border
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: rect];
    }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method to determine if we can accept the drop
     --------------------------------------------------------*/
    //finished with the drag so remove any highlighting
    highlight=NO;
    
    [self setNeedsDisplay: YES];
    
    //check to see if we can accept the data
    return YES;
} 

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method that should handle the drop data
     --------------------------------------------------------*/
    if ( [sender draggingSource] != self ) {
        
        NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        if ([[[draggedFilenames objectAtIndex:0] pathExtension] isEqual:@"ipa"]){
            NSLog(@"%@",[draggedFilenames objectAtIndex:0]);
            
            NSLog(@"%@",[self desktopDirectory]);
            
            [self getImageFromIPA:[draggedFilenames objectAtIndex:0]];
            return YES;
        }
        else
            return NO;
    }
    
    return YES;
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame;
{
    /*------------------------------------------------------
     delegate operation to set the standard window frame
     --------------------------------------------------------*/
    //get window frame size
    NSRect ContentRect=self.window.frame;
    
    //set it to the image frame size
    ContentRect.size=[[self image] size];
    
    return [NSWindow frameRectForContentRect:ContentRect styleMask: [window styleMask]];
};

#pragma mark - Source Operations

- (void)mouseDown:(NSEvent*)event
{  
    // When Clicked on View
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    /*------------------------------------------------------
     NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
     --------------------------------------------------------*/
    switch (context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy;
            
            //by using this fall through pattern, we will remain compatible if the contexts get more precise in the future.
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationCopy;
            break;
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event 
{
    /*------------------------------------------------------
     accept activation click as click in window
     --------------------------------------------------------*/
    //so source doesn't have to be the active window
    return YES;
}

- (void)pasteboard:(NSPasteboard *)sender item:(NSPasteboardItem *)item provideDataForType:(NSString *)type
{
    /*------------------------------------------------------
     method called by pasteboard to support promised 
     drag types.
     --------------------------------------------------------*/
    //sender has accepted the drag and now we need to send the data for the type we promised
    if ( [type compare: NSPasteboardTypeTIFF] == NSOrderedSame ) {
        
        //set data for TIFF type on the pasteboard as requested
        [sender setData:[[self image] TIFFRepresentation] forType:NSPasteboardTypeTIFF];
        
    } else if ( [type compare: NSPasteboardTypePDF] == NSOrderedSame ) {
        
        //set data for PDF type on the pasteboard as requested
        [sender setData:[self dataWithPDFInsideRect:[self bounds]] forType:NSPasteboardTypePDF];
    }
    
}


- (void)getImageFromIPA:(NSString *)ipaPath
{
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:ipaPath]) {
        NSLog(@"IPA Path not Exists");
        return;
    }
    
    NSString *tempDir = [self createTempDirectoryForUnzip];
    if (!tempDir) {
        NSLog(@"Can not create temp dir");
        return;
        
    }
    
    // Get File Name and Exact extension
    NSString *appFile = [[ipaPath pathComponents] lastObject];
    NSString *appName = [appFile stringByDeletingPathExtension];
    dispatch_queue_t unzipGCD = dispatch_queue_create("com.simpletail.unzipGCD", 0);
    
    dispatch_sync(unzipGCD, ^{
        // Create Temp for Unzip Folder and unzip it
        NSTask *unzipTask = [NSTask new];
        [unzipTask setLaunchPath:@"/usr/bin/unzip"];
        
        NSArray *unzipArg = [NSArray arrayWithObjects:@"-q",ipaPath,@"-d",tempDir, nil];
        [unzipTask setArguments:unzipArg];
        [unzipTask launch];
        [unzipTask waitUntilExit];
    });
    
    // Grap All File In payload Folder
    NSString *payloadDir = [tempDir stringByAppendingPathComponent:@"/Payload/"];
    NSArray *fileInPayload = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:payloadDir error:nil];
    
    NSString *appPayload = [payloadDir stringByAppendingPathComponent:[fileInPayload objectAtIndex:0]];
    
    NSArray *contentFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appPayload error:nil];
    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] '.png'"];
    
    NSArray *pngFiles = [contentFiles filteredArrayUsingPredicate:aPredicate];
    NSLog(@"%@",contentFiles);

    
    
    NSString *desktopPath = [self desktopDirectory];
    NSString *assetPath = [desktopPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-Files",appName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:assetPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:assetPath withIntermediateDirectories:YES attributes:nil error:nil];
    }else {
        // Remove Old Folder and Create new
        [[NSFileManager defaultManager] removeItemAtPath:assetPath error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:assetPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    static int count = 0;
    NSString *pngCrushPath = [[NSBundle mainBundle] pathForResource:@"pngcrush" ofType:nil];
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (NSString *filename in pngFiles) {
                NSTask *crushTask = [NSTask new];
                [crushTask setLaunchPath:pngCrushPath];
                
                NSMutableArray *arg = [NSMutableArray new];
                [arg addObject:@"-q"];
                [arg addObject:@"-revert-iphone-optimizations"];
                [arg addObject:@"-d"];
                
                // Desc Folder
                [arg addObject:assetPath];
                
                // Source
                NSString *sourcePath = [appPayload stringByAppendingPathComponent:filename];
                [arg addObject:sourcePath];
                
                [crushTask setArguments:arg];
                [crushTask launch];
                [crushTask waitUntilExit];
                
                [arg removeAllObjects];
                arg = nil;
                crushTask = nil;
                count++;
            }
        });
    
    NSLog(@"Done");

    
}

- (NSString *)createTempDirectoryForUnzip
{
    NSString *appDocDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *tempFolder = [appDocDir stringByAppendingPathComponent:@"ACUI/unzipped/"];
    NSLog(@"%@",tempFolder);
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"Create Temp Folder");
    }else {
        [[NSFileManager defaultManager] removeItemAtPath:tempFolder error:nil];
        NSLog(@"Delete Temp Folder");
        
        [[NSFileManager defaultManager] createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"Recreate Temp Folder");
    }
    
    return tempFolder;
}

- (NSString *)desktopDirectory
{
    NSString *homeDir = NSHomeDirectory();
    NSString *desktopDir = [homeDir stringByAppendingPathComponent:@"Desktop"];
    return desktopDir;
}




@end
