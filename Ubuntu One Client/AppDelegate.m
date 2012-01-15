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
#import "AsynchronAdapterOperation.h"
#import "FileWritingAsynchronAdapterDelegate.h"
#import "DownloadFileAttributeAsynchronAdapterDelegate.h"
#import "ContentAdapter.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    AuthorizationDetails *authorizationDetails = [AuthorizationDetails readFromApplicationSupportDirectory];

    NSString *absolutePath = @"/Users/user/Ubuntu One/foo.sh";
    FileWritingAsynchronAdapterDelegate *fileWritingDelegate = [[FileWritingAsynchronAdapterDelegate alloc] initWithAbsolutePath:absolutePath];
    
    ContentAdapter *adapter = [ContentAdapter adapterWithContentPath:@"/content/~/Ubuntu One/foo.sh" authorizationDetails:authorizationDetails andDelegates:[NSArray arrayWithObject:fileWritingDelegate]];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    AsynchronAdapterOperation *operation = [AsynchronAdapterOperation adapterOperationWithAsynchronAdapter:adapter];
    [queue addOperation:operation];
}
@end
