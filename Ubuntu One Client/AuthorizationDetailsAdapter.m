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

#import "AuthorizationDetailsAdapter.h"

@implementation AuthorizationDetailsAdapter
@synthesize username = _username;
@synthesize password = _password;
@synthesize delegate = _delegate;

+ (void)requestWithUsername:(NSString*)username password:(NSString*)password andDelegate:(id<AuthorizationDetailsAdapterDelegate>)delegate {
    AuthorizationDetailsAdapter *adapter = [[AuthorizationDetailsAdapter alloc] init];
    adapter.username = username;
    adapter.password = password;
    adapter.delegate = delegate;
    
    NSString *nameOfExecutable = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSString *tokenName = [@"Ubuntu%20One%20@%20" stringByAppendingString:[nameOfExecutable stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *url = [@"https://login.ubuntu.com/api/1.0/authentications?ws.op=authenticate&token_name=" stringByAppendingString:tokenName];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection connectionWithRequest:request delegate:adapter];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate
- (void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (challenge.previousFailureCount > 1) {
        [challenge.sender cancelAuthenticationChallenge:challenge];
    } else {
        [challenge.sender useCredential:[NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone] forAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate didFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary *objects = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];

    self.authorizationDetails = [AuthorizationDetails authorizationDetailsWithObjects:objects];
    self.url = [@"https://one.ubuntu.com/oauth/sso-finished-so-get-tokens/" stringByAppendingString:self.username];
    NSData *data = [self requestData];
    
#ifdef DEBUG
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
    NSLog(@"%@", dataString);
#endif
    
    [self.delegate didFinishWithAuthorizationDetails:self.authorizationDetails];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    if (_responseData) {
        [_responseData setLength:0];
    }
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_responseData == nil) {
        _responseData = [[NSMutableData alloc] initWithData:data];
    } else {
        [_responseData appendData:data];
    }
}

@end
