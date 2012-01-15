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

#import "AsynchronAdapter.h"

@implementation AsynchronAdapter {
@private
    NSMutableArray *_delegates;
}

#pragma mark -
#pragma mark initialization methods
- (id)initWithUrl:(NSString*)url authorizationDetails:(AuthorizationDetails*)authorizationDetails andDelegates:(NSArray*)delegates {
    self = [super initWithUrl:url andAuthorizationDetails:authorizationDetails];
    if (self) {
        _delegates = [NSMutableArray array];
        [delegates enumerateObjectsUsingBlock:^(id<AsynchronAdapterDelegate> delegate, NSUInteger idx, BOOL *stop) {
            [self addDelegate:delegate];
        }];
    }

    return self;
}

#pragma mark -
#pragma mark ...
- (void)request {
    NSURLRequest *request = [self constructRequest];
    
#ifdef DEBUG
    NSLog(@"requesting %@", request.URL.absoluteString);
#endif
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_delegates enumerateObjectsUsingBlock:^(id<AsynchronAdapterDelegate> obj, NSUInteger idx, BOOL *stop) {
        [obj didReceiveData:data];
    }];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_delegates enumerateObjectsUsingBlock:^(id<AsynchronAdapterDelegate> obj, NSUInteger idx, BOOL *stop) {
        [obj didFailWithError:error];
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    // ...
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [_delegates enumerateObjectsUsingBlock:^(id<AsynchronAdapterDelegate> obj, NSUInteger idx, BOOL *stop) {
        [obj didFinishLoading];
    }];
}

#pragma mark -
#pragma mark add/remove delegates
- (void)addDelegate:(id<AsynchronAdapterDelegate>) delegate {
    NSAssert(delegate, @"delegate must not be null.");
    NSAssert(_delegates, @"_delegates must not be null.");
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<AsynchronAdapterDelegate>) delegate {
    NSAssert(delegate, @"delegate must not be null.");
    NSAssert(_delegates, @"_delegates must not be null.");
    [_delegates removeObject:delegate];
}

@end
