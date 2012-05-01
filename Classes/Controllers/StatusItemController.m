/* Copyright (c) 2012 Yevgeniy Melnichuk, Chris Ledet
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
#import "UserSettings.h"
#import "AppDelegate.h"

@implementation StatusItemController

@synthesize menu, progressDelegateFactory = _progressDelegateFactory;

- (void)awakeFromNib
{
    AppDelegate* appDelegate = (AppDelegate*) [[NSApplication sharedApplication] delegate];
    statusItem = [appDelegate statusMenuItem];
    statusItem.menu = self.menu;
}

- (IBAction)clickedSyncNowMenuItem:(NSMenuItem *)sender {
    
    AuthorizationDetails *authorizationDetails = [AuthorizationDetails current];
    
    SyncWorker *syncWorker = [[SyncWorker alloc] initWithAbsoluteRootPath:[UserSettings syncLocation] andAuthorizationDetails:authorizationDetails];

    [syncWorker addDelegateFactory:_progressDelegateFactory];
    
    // TODO: Use GCD aync block 
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
