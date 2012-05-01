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


#import "GeneralOptionsController.h"
#import "UserSettings.h"
#import "AppDelegate.h"

@interface GeneralOptionsController(Private)
- (NSOpenPanel *)setUpOpenPanel;
- (void)setUpView;
- (void)setUpLocationPopOut;
@end

@implementation GeneralOptionsController

@synthesize locationPopUpButton, versionTextField, colorMenuIconButton;

- (IBAction)clickedColorMenuIconButton:(id)sender
{
    BOOL coloredIcon = colorMenuIconButton.state == NSOnState;
    [UserSettings setColorMenuIconSwitch:coloredIcon];
    NSString* imageName = (coloredIcon ? kColorMenuIconName : kBlackMenuIconName);
    
    AppDelegate* appDelegate = (AppDelegate*) [[NSApplication sharedApplication] delegate];
    [appDelegate setStatusMenuItemIcon:imageName];
}

- (IBAction)clickedSelectLocationButton:(id)sender
{    
    NSOpenPanel* openPanel = [self setUpOpenPanel];
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger returnCode) {
        if (returnCode == NSOKButton) {
            
            NSURL* selectedDirURL = [openPanel.URLs objectAtIndex:0];
            [UserSettings setSyncLocation:[NSString pathWithComponents:selectedDirURL.pathComponents]];

            [self setUpLocationPopOut];
        }
    }];

    // Reset PopUp menu to first item
    [locationPopUpButton selectItemAtIndex:0];
}

- (id)initWithContentFromNib {
    self = [super initWithNibName:@"GeneralOptions" bundle:nil];
    if (self) {
        // ...
    }

    return self;
}

- (void) awakeFromNib
{
    [self setUpView];
}



/* Private Methods */

- (NSOpenPanel*)setUpOpenPanel
{
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    
    return openPanel;
}

- (void)setUpLocationPopOut
{
    NSString* location = [[NSUserDefaults standardUserDefaults] stringForKey:kLocalFolder];
    
    // Set first item title to the current location
    NSArray* menuItemsArray = locationPopUpButton.menu.itemArray;
    [[menuItemsArray objectAtIndex:0] setTitle:location];
}

- (void)setUpView
{
    [self setUpLocationPopOut];

    versionTextField.objectValue = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    colorMenuIconButton.state = [UserSettings colorMenuIconSwitch];
}

@end
