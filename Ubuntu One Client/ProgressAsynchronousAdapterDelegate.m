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

#import "ProgressAsynchronousAdapterDelegate.h"

@implementation ProgressAsynchronousAdapterDelegate {
@private
    NSArrayController *_progressEntries;
    NSMutableDictionary *_objects;
}

- (id)initWithProgressentries:(NSArrayController*)progressEntries andObjects:(NSDictionary*)objects {
    NSAssert(progressEntries, @"progressEntries must not be null.");

    self = [super init];
    if (self) {
        _progressEntries = progressEntries;
        _objects = [NSMutableDictionary dictionaryWithDictionary:objects];

        [_objects setObject:[_objects objectForKey:@"filename"] forKey:@"description"];
    }

    return self;
}

- (void)willStartLoading {
    NSAssert(_progressEntries, @"_progressEntries must not be null");
    NSAssert(_objects, @"_objects must not be null");

    [_progressEntries addObject:_objects];
}

- (void)didReceiveData:(NSData*)data {
    // ...
}

- (void)didFailWithError:(NSError*)error {
    [_progressEntries removeObject:_objects];
}

- (void)didFinishLoading {
    [_progressEntries removeObject:_objects];    
}
@end
