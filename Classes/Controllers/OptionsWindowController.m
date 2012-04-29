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
#import "GeneralOptionsController.h"

@interface OptionsWindowController (Private)
- (void)setContentViewAndResiize:(NSView*)view;
- (void)refreshAccountTab;
@end

@implementation OptionsWindowController{
@private
    UserDetailsController *_userDetailsController;
    GeneralOptionsController *_generalOptionsController;
}

@synthesize loginWindow, usernameTextfield, passwordTextfield, generalToolbarItem, accountToolbarItem, toolbar;

- (void)refreshAccountTab
{
    AuthorizationDetails *authorizationDetails = [AuthorizationDetails current];
    if (authorizationDetails) {
        [self setContentViewAndResiize:_userDetailsController.view];
        [_userDetailsController refreshUserDetails];
    } else {
        [NSApp beginSheet:loginWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (void)setContentViewAndResiize:(NSView*)view
{
    NSWindow *window = self.window;
    NSRect frame = view.frame;
//    NSRect newFrame = [window frameRectForContentRect:frame];
//    newFrame.origin = window.frame.origin;

    view.frame = NSMakeRect(0, 0, frame.size.width, frame.size.height);

//    [window setFrame:newFrame display:YES animate:YES];
    [window.contentView setSubviews:[NSArray arrayWithObject:view]];
}

- (id)initWithContentFromNib
{
    self = [super initWithWindowNibName:@"OptionsWindow"];
    if (self) {
        
        if (!_generalOptionsController) {
            _generalOptionsController = [[GeneralOptionsController alloc] initWithContentFromNib];
        }
        
        if (!_userDetailsController) {
            _userDetailsController = [[UserDetailsController alloc] initWithContentFromNib];
        }
    }

    return self;
}

- (void)windowDidLoad
{
    // Show General options view and hightlight it on Tool Bar
    if (toolbar) {
        [toolbar setSelectedItemIdentifier:generalToolbarItem.itemIdentifier];
    }
    [self setContentViewAndResiize:_generalOptionsController.view];
}

- (void)awakeFromNib {
    [self.window setReleasedWhenClosed:NO];
}

#pragma mark -
#pragma mark Toolbar Actions
- (IBAction)clickedAccountToolbarItem:(NSToolbarItem *)sender {
    [self refreshAccountTab];
}

- (IBAction)clickedGeneralToolbarItem:(NSToolbarItem *)sender {
    [self setContentViewAndResiize:_generalOptionsController.view];
}

#pragma mark -
#pragma mark LoginForm Actions

- (IBAction)clickedRequestAuthorizationButton:(NSButton *)sender {
    NSString *username = self.usernameTextfield.stringValue;
    NSString *password = self.passwordTextfield.stringValue;
    
    [AuthorizationDetailsAdapter requestWithUsername:username password:password andDelegate:self];
}

- (IBAction)clickedCancelAuthorizationButton:(NSButton *)sender {
    [NSApp endSheet:self.loginWindow];
}

#pragma mark -
#pragma mark AuthorizationDetailsAdapterDelegate
- (void)didFinishWithAuthorizationDetails:(AuthorizationDetails*)authorizationDetails
{
    [authorizationDetails writeToApplicationSupportDirectory];

    [NSApp endSheet:self.loginWindow];
    [self refreshAccountTab];
}

- (void)didFailWithError:(NSError*)error
{
    NSLog(@"%s with error: %@", __PRETTY_FUNCTION__, error);
    
    [NSApp endSheet:self.loginWindow];
    [self refreshAccountTab];
}

@end
