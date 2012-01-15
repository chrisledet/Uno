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

#import "SynchronAdapter.h"
#import "OAuthConsumer.h"

@implementation SynchronAdapter

#pragma mark -
#pragma mark request data
- (NSData*)requestDataWithRequest:(NSURLRequest*)request {
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
#ifdef DEBUG
    NSLog(@"requesting %@", self.url);
#endif
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"%s with error: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    return data;
}

- (NSData*)requestData {
    return [self requestDataWithRequest:[self constructRequest]];
}

#pragma mark -
#pragma mark request objects(NSDictionary/NSArray)
- (id)requestObjectsWithRequest:(NSURLRequest*)request {
    NSData *data = [self requestDataWithRequest:request];

    NSError *error = nil;
    id objects = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"%s with error: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    return objects;    
}

- (id)requestObjects {
    return [self requestObjectsWithRequest:[self constructRequest]];
}

@end
