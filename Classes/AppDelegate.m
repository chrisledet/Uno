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

#import "AppDelegate.h"
#import "AuthorizationDetailsAdapter.h"
#import "NodeDetailsAdapter.h"
#import "UserDetailsAdapter.h"
#import "AsynchronousAdapterOperation.h"
#import "FileWritingAsynchronousAdapterDelegate.h"
#import "ContentAdapter.h"
#import "ContentUploadAdapter.h"
#import "FileAttributesUpdatingAsynchronAdapterDelegate.h"
#import "UserSettings.h"

//@interface AppDelegate(Private)
//- (void) setStatusMenuItem;
//@end

@implementation AppDelegate
@synthesize window = _window;

- (void)setupDefaultSettings
{
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    // Default sync location
    NSString *defaultLocalFolder = [@"~/Ubuntu One" stringByExpandingTildeInPath];
    [defaultValues setObject:defaultLocalFolder forKey:kLocalFolder];
    
    // Default menu icon color
    [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:kMenuIconColored];
    
    // Set defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupDefaultSettings];
}

- (NSStatusItem*)statusMenuItem
{
    if (!statusMenuItem) {
        statusMenuItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
        statusMenuItem.highlightMode = YES;
        
        NSString* imageName = [UserSettings colorMenuIconSwitch] ? kColorMenuIconName : kBlackMenuIconName;
        [self setStatusMenuItemIcon:imageName];
    }
    
    return statusMenuItem;
}

- (void)setStatusMenuItemIcon:(NSString*)imageName
{
    NSStatusBar* systemStatusBar = NSStatusBar.systemStatusBar;
    NSImage* menuImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:imageName]];
    menuImage.scalesWhenResized = YES;
    menuImage.size = NSMakeSize(systemStatusBar.thickness - 1, systemStatusBar.thickness - 1);
    statusMenuItem.image = menuImage;
}

@end
