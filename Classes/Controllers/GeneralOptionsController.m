#import "GeneralOptionsController.h"

@interface GeneralOptionsController(Private)
- (NSOpenPanel *)setUpOpenPanel;
- (void)setUbuntuOneDirectoryLocation:(NSString*)path;
@end

@implementation GeneralOptionsController

@synthesize locationPopUpButton;

- (NSOpenPanel *)setUpOpenPanel {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];

    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    
    return openPanel;
}

- (void)setUbuntuOneDirectoryLocation:(NSString*)dirPath
{
    if (dirPath && [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:nil]) {
#if DEBUG
        NSLog(@"Setting new directory: %@", dirPath);
#endif
        [[NSUserDefaults standardUserDefaults] setObject:dirPath forKey:kLocalFolder];
        
    }
}

- (IBAction)clickedSelectLocationButton:(id)sender
{    
    NSOpenPanel* openPanel = [self setUpOpenPanel];
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger returnCode) {
        if (returnCode == NSOKButton) {
            NSURL* selectedDirURL = [openPanel.URLs objectAtIndex:0];
#if DEBUG
            NSLog(@"Selected Directory: %@", selectedDirURL.relativeString);
#endif
            [self setUbuntuOneDirectoryLocation:[NSString pathWithComponents:selectedDirURL.pathComponents]];
            [self setUpPopUpMenu];
        }
    }];

    // Reset PopUp menu to first item
    [locationPopUpButton selectItemAtIndex:0];
}

- (void) setUpPopUpMenu
{
    NSString* location = [[NSUserDefaults standardUserDefaults] stringForKey:kLocalFolder];
    
    // Set first item title to the current location
    NSArray* menuItemsArray = locationPopUpButton.menu.itemArray;
    [[menuItemsArray objectAtIndex:0] setTitle:location];
}

- (id) initWithContentFromNib {
    self = [super initWithNibName:@"GeneralOptions" bundle:nil];
    if (self) {
        // ...
    }

    return self;
}

- (void) awakeFromNib
{
    [self setUpPopUpMenu];
}

@end
