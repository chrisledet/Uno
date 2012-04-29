/* Copyright (C) 2012 Yevgeniy Melnichuk <yevgeniy.melnichuk@googlemail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "StatusItemController.h"
#import "NSBundle+ApplicationName.h"
#import "SyncWorker.h"
#import "Constants.h"

@implementation StatusItemController

@synthesize menu, progressDelegateFactory = _progressDelegateFactory;

- (void)awakeFromNib
{
    NSStatusBar *systemStatusBar = NSStatusBar.systemStatusBar;

    NSString *iconPath =[[NSBundle mainBundle] pathForImageResource:@"u1"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:iconPath];
    image.scalesWhenResized = YES;
    image.size = NSMakeSize(systemStatusBar.thickness - 1, systemStatusBar.thickness - 1);

    statusItem = [systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
    statusItem.image = image;
    statusItem.highlightMode = YES;
    statusItem.menu = self.menu;
}

- (IBAction)clickedSyncNowMenuItem:(NSMenuItem *)sender {
    
    AuthorizationDetails *authorizationDetails = [AuthorizationDetails current];
    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:kLocalFolder];    
    SyncWorker *syncWorker = [[SyncWorker alloc] initWithAbsoluteRootPath:path andAuthorizationDetails:authorizationDetails];

    [syncWorker addDelegateFactory:_progressDelegateFactory];
    [syncWorker sync];
}

- (IBAction)clickedOptionsMenuItem:(NSMenuItem *)sender {
    if (!optionsWindowController) {
        optionsWindowController = [[OptionsWindowController alloc] initWithContentFromNib];
    }
    
    [optionsWindowController.window center];
    [optionsWindowController.window makeKeyAndOrderFront:self];
}

- (IBAction)clickedBuyMoreStorageMenuItem:(NSMenuItem *)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kBuyMoreStorageURLString]];
}

- (IBAction)clickedOpenLocationMenuItem:(NSMenuItem *)sender
{
     NSString* path = [[NSUserDefaults standardUserDefaults] stringForKey:kLocalFolder];   
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:path]];
}

@end
