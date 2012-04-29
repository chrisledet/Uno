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

#import "FileAttributesUpdatingAsynchronAdapterDelegate.h"
#import "NodeDetails.h"
#import "FileAttributesHelper.h"

@implementation FileAttributesUpdatingAsynchronAdapterDelegate {
@private
    NSString *_absolutePath;
    NSMutableData *_data;
}

- (id)initWithAbsolutePath:(NSString*)absolutePath {
    self = [super init];
    if (self) {
        _absolutePath = absolutePath;
    }

    return self;
}

- (void)willStartLoading {
    // ...
}

- (void)didReceiveData:(NSData*)data {
    if (!_data) {
        _data = [NSMutableData dataWithData:data];
    } else {
        [_data appendData:data];
    }
}

- (void)didFailWithError:(NSError*)error {
    NSLog(@"%s failed with error: %@", __PRETTY_FUNCTION__, error);
}

- (void)didFinishLoading {
    NSError *error = nil;
    NSDictionary *objects = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
    if (error) {
        NSLog(@"%s failed with error: %@", __PRETTY_FUNCTION__, error);

        NSString *dataString = [[NSString alloc] initWithData:_data encoding:NSISOLatin1StringEncoding];
        NSLog(@"data: %@", dataString);
        
        return;
    }
    
    NodeDetails *nodeDetails = [NodeDetails nodeDetailsWithObjects:objects];
    [FileAttributesHelper updateFileAttributes:_absolutePath withNodeDetails:nodeDetails];
}
@end
