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

#import "ContentUploadAdapter.h"
#import "MIMETypeResolver.h"

@interface ContentUploadAdapter (Private)
- (ContentUploadAdapter*)initWithAbsolutePath:(NSString*)path directoryContentPath:(NSString*)contentPath authorizationDetails:(AuthorizationDetails*)authorizationDetails andDelegates:(NSArray*)delegates;
@end

@implementation ContentUploadAdapter {
@private
    NSString *_absolutePath;
}

#pragma mark -
#pragma mark static initialization methods
+ (ContentUploadAdapter*) adapterWithAbsolutePath:(NSString*)absolutePath directoryContentPath:(NSString*)contentPath authorizationDetails:(AuthorizationDetails*)authorizationDetails andDelegates:(NSArray*)delegates {
    return [[ContentUploadAdapter alloc] initWithAbsolutePath:absolutePath directoryContentPath:contentPath authorizationDetails:authorizationDetails andDelegates:delegates];
}

#pragma mark -
#pragma mark initialization methods
- (ContentUploadAdapter*)initWithAbsolutePath:(NSString*)absolutePath directoryContentPath:(NSString*)contentPath authorizationDetails:(AuthorizationDetails*)authorizationDetails andDelegates:(NSArray*)delegates {
        NSString *url = [NSString stringWithFormat:@"https://files.one.ubuntu.com%@/%@", contentPath, absolutePath.lastPathComponent];
    self = [super initWithUrl:url authorizationDetails:authorizationDetails andDelegates:delegates];
    if (self) {
        _absolutePath = absolutePath;
    }
    
    return self;
}

#pragma mark -
#pragma mark AbstractAdapter
- (NSMutableURLRequest*)constructRequest {
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_absolutePath error:&error];
    if (error) {
        NSLog(@"%s failed with erro: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }

    NSNumber *contentLength = [attributes objectForKey:NSFileSize];
    NSString *contentType = [MIMETypeResolver mimetypeForFile:_absolutePath];
    
    NSMutableURLRequest *request = [super constructRequest];
    request.HTTPMethod = @"PUT";
    request.HTTPBodyStream = [NSInputStream inputStreamWithFileAtPath:_absolutePath];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:contentLength.stringValue forHTTPHeaderField:@"Content-Length"];
    
    return request;
}

#pragma mark -
#pragma mark other methods
+ (void)uploadFile:(NSString*)absolutePath withDirectoryContentPath:(NSString*)contentPath authorizationDetails:(AuthorizationDetails*)authorizationDetails andDelegates:(NSArray*)delegates {
    ContentUploadAdapter *adapter = [[ContentUploadAdapter alloc] initWithAbsolutePath:absolutePath directoryContentPath:contentPath authorizationDetails:authorizationDetails andDelegates:delegates];
    
    [adapter request];
}

@end
