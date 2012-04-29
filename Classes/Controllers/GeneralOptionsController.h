#import <Cocoa/Cocoa.h>

@interface GeneralOptionsController : NSViewController {
    NSPopUpButton* locationPopUpButton;
}

@property (strong, nonatomic) IBOutlet NSPopUpButton* locationPopUpButton;

- (IBAction)clickedSelectLocationButton:(id)sender;
- (id)initWithContentFromNib;

@end
