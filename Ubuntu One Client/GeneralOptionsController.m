#import "GeneralOptionsController.h"

@interface GeneralOptionsController(Private)
- (NSOpenPanel *)createOpenPanel;
- (void)addPathToCacheIfNeeded:(NSString*)path;
@end

@implementation GeneralOptionsController

#pragma -
#pragma mark Local Folder Handling
- (NSOpenPanel *)createOpenPanel {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;

    return openPanel;
}

- (void)addPathToCacheIfNeeded:(NSString*)path {
    NSAssert(path, @"path must not be null.");

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *cachedLocalFolders = [userDefaults arrayForKey:kCachedLocalFolders];
    if (![cachedLocalFolders containsObject:path]) {
        NSMutableArray *newCachedLocalFolder = [NSMutableArray arrayWithObject:path];
        [newCachedLocalFolder addObjectsFromArray:cachedLocalFolders];
        
        [newCachedLocalFolder sortUsingComparator:^NSComparisonResult(NSString *path1, NSString *path2) {
            NSString *filename1 = path1.lastPathComponent;
            NSString *filename2 = path2.lastPathComponent;
            return [filename1 compare:filename2 options:NSCaseInsensitiveSearch];
        }];
        
        [userDefaults setObject:newCachedLocalFolder forKey:kCachedLocalFolders];
    }
}

- (IBAction)clickedChooseButton:(id)sender {
    NSOpenPanel *openPanel;
    openPanel = [self createOpenPanel];    
    if ([openPanel runModal] == NSOKButton) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSURL *url = [openPanel.URLs objectAtIndex:0];
        NSString *path = [NSString pathWithComponents:url.pathComponents];
        
        [self addPathToCacheIfNeeded:path];
        [userDefaults setObject:path forKey:kLocalFolder];
    }
}

- (id)initWithContentFromNib {
    self = [super initWithNibName:@"GeneralOptions" bundle:nil];
    if (self) {
        // ...
    }

    return self;
}

@end
