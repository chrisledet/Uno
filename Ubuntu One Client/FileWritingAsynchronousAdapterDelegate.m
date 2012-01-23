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

#import "FileWritingAsynchronousAdapterDelegate.h"
#import "FileAttributesHelper.h"

@implementation FileWritingAsynchronousAdapterDelegate{
@private
    NSString *_absolutePath;
    NodeDetails *_nodeDetails;
    NSFileHandle *_fileHandle;
}

- (id)initWithAbsolutePath:(NSString*)path andNodeDetails:(NodeDetails*)nodeDetails {
    self = [super init];
    if (self) {
        _absolutePath = [path stringByExpandingTildeInPath];
        _nodeDetails = nodeDetails;
    }

    return self;
}

- (void)willStartLoading {
    [[NSFileManager defaultManager] createFileAtPath:_absolutePath contents:nil attributes:nil];
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_absolutePath];
}

- (void)didReceiveData:(NSData *)data {
    [_fileHandle writeData:data];
}

- (void)didFailWithError:(NSError*)error {
    [_fileHandle closeFile];
}

- (void)didFinishLoading {
    [_fileHandle closeFile];
    [FileAttributesHelper updateFileAttributes:_absolutePath withNodeDetails:_nodeDetails];
}

@end
