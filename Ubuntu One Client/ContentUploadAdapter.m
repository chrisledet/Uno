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
#import "AuthorizationDetails.h"
#import "OAuthConsumer.h"
#import "MIMETypeResolver.h"

@implementation ContentUploadAdapter
+ (void)uploadFile:(NSString*)path withDirectoryContentPath:(NSString*)directoryContentPath andAuthorizationDetails:(AuthorizationDetails*)authorizationDetails{

    NSString *contentPath = [directoryContentPath stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
    NSString *url = [NSString stringWithFormat:@"https://files.one.ubuntu.com%@/%@", contentPath, path.lastPathComponent];

    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSNumber *contentLength = [attributes objectForKey:NSFileSize];
    NSString *contentType = [MIMETypeResolver mimetypeForFile:path];
    
    ContentUploadAdapter *contentUploader = [[ContentUploadAdapter alloc] initWithUrl:url andAuthorizationDetails:authorizationDetails];
    
    NSMutableURLRequest *request = [contentUploader constructRequest];
    request.HTTPMethod = @"PUT";
    request.HTTPBodyStream = [NSInputStream inputStreamWithFileAtPath:path];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:contentLength.stringValue forHTTPHeaderField:@"Content-Length"];

    NSDictionary *objects = [contentUploader requestObjectsWithRequest:request];
    NodeDetails *nodeDetails = [NodeDetails nodeDetailsWithObjects:objects];
    [contentUploader updateFileAttributesForFile:path withNodeDetails:nodeDetails];
}

- (void)updateFileAttributesForFile:(NSString*)path withNodeDetails:(NodeDetails*)nodeDetails {
    NSAssert(path, @"path must not be null.");
    NSAssert(nodeDetails, @"nodeDetails must not be null.");

    NSError *error = nil;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    [attributes setObject:nodeDetails.whenCreated forKey:NSFileCreationDate];
    [attributes setObject:nodeDetails.whenChanged forKey:NSFileModificationDate];

    [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:path error:&error];
    if (error) {
        NSLog(@"%s with error: %@", __PRETTY_FUNCTION__, error);
    }
}
@end