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

#import "UserDetailsController.h"
#import "AuthorizationDetails.h"
#import "UserDetailsAdapter.h"
#import "UserDetails.h"
#import "NSNumber+numberToHumanSize.h"

@implementation UserDetailsController
@synthesize userTextField;
@synthesize availableTextField;
@synthesize usedTextField;
@synthesize percentageIndicator;

- (id)initWithContentFromNib {
    self = [super initWithNibName:@"UserDetails" bundle:nil];
    return self;
}

- (void)awakeFromNib {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    usedTextField.formatter = formatter;
    availableTextField.formatter = formatter;
    
    percentageIndicator.maxValue = 100; // 100%
}

- (void)refreshUserDetails {
    AuthorizationDetails *authorizationDetails = [AuthorizationDetails current];
    
    UserDetails *userDetails = [UserDetailsAdapter requestWithAuthorizationDetails:authorizationDetails];
    userTextField.stringValue = userDetails.name;
    
    NSNumber *bytesAvailabe = userDetails.bytesAvailable;
    NSNumber *bytesUsed     = userDetails.bytesInUse;
    double perecentUsed = 100.0 / [bytesAvailabe doubleValue] * [bytesUsed doubleValue];
    
    usedTextField.stringValue      = [NSString stringWithFormat:@"%@ (%.2f%s)", [bytesUsed numberToHumanSize], perecentUsed, "%"];
    availableTextField.stringValue = [bytesAvailabe numberToHumanSize];
    
    percentageIndicator.doubleValue = perecentUsed;
}

@end
