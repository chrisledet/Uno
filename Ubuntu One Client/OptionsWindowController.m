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

#import "OptionsWindowController.h"
#import "AuthorizationDetails.h"

@interface OptionsWindowController (Private)
- (void)setContentViewAndResiize:(NSView*)view;
@end

@implementation OptionsWindowController{
@private
    UserDetailsController *_userDetailsController;
}

@synthesize loginWindow;
@synthesize usernameTextfield;
@synthesize passwordTextfield;
@synthesize accountToolbarItem;

- (void)refreshAccountTab {
    AuthorizationDetails *authorizationDetails = [AuthorizationDetails current];
    if (authorizationDetails) {
        if (!_userDetailsController) {
            _userDetailsController = [[UserDetailsController alloc] initWithContentFromNib];
        }
        
        [self setContentViewAndResiize:_userDetailsController.view];
        [_userDetailsController refreshUserDetails];
    } else {
        [NSApp beginSheet:loginWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

- (void)setContentViewAndResiize:(NSView*)view {
    NSWindow *window = self.window;
    NSRect newFrame = [window frameRectForContentRect:view.frame];

    newFrame.origin = window.frame.origin;
    
    [window setFrame:newFrame display:YES animate:YES];
    [window setContentView:view];
}

- (id)initWithContentFromNib {
    self = [super initWithWindowNibName:@"OptionsWindow"];
    if (self) {
        // ...
    }

    return self;
}

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // ...
    }
    
    return self;
}

- (void)windowDidLoad {
    [self refreshAccountTab];
    // [super windowDidLoad];
}

- (void)awakeFromNib {
    [self.window setReleasedWhenClosed:NO];
}

#pragma mark -
#pragma mark actions
- (IBAction)clickedAccountToolbarItem:(NSToolbarItem *)sender {
    [self refreshAccountTab];
}

- (IBAction)clickedRequestAuthorizationButton:(NSButton *)sender {
    NSString *username = self.usernameTextfield.stringValue;
    NSString *password = self.passwordTextfield.stringValue;
    
    [AuthorizationDetailsAdapter requestWithUsername:username password:password andDelegate:self];
}

- (IBAction)clickedCancelAuthorizationButton:(NSButton *)sender {
    [NSApp endSheet:self.loginWindow];
}

#pragma mark -
#pragma mark AuthorizationDetailsRequesterDelegate
- (void)didFinishWithAuthorizationDetails:(AuthorizationDetails*)authorizationDetails {
    [authorizationDetails writeToApplicationSupportDirectory];

    [NSApp endSheet:self.loginWindow];
    [self refreshAccountTab];
}

- (void)didFailWithError:(NSError*)error {
    NSLog(@"%s with error: %@", __PRETTY_FUNCTION__, error);
    
    [NSApp endSheet:self.loginWindow];
    [self refreshAccountTab];
}

@end
