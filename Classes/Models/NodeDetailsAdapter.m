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

#import "NodeDetailsAdapter.h"

@interface NodeDetailsAdapter (Private)
+ (NodeDetails*)createNodeWithKind:(NSString*)kind resourcePath:(NSString*)resourcePath andAuthorizationDetails:(AuthorizationDetails*)authorizationDetails;
@end

@implementation NodeDetailsAdapter
+ (NodeDetails*)requestNodePath:(NSString*)nodePath withAuthorizationDetails:(AuthorizationDetails*)authorizationDetails andIncludingChildren:(BOOL)includingChildren {
    NSString *url = [@"https://one.ubuntu.com/api/file_storage/v1" stringByAppendingString:nodePath];
    
    if (includingChildren) {
        url = [url stringByAppendingString:@"?include_children=true"];
    }
    
    NodeDetailsAdapter *adapter = [[NodeDetailsAdapter alloc] initWithUrl:url andAuthorizationDetails:authorizationDetails];
    NSDictionary *objects = [adapter requestObjects];

    return [NodeDetails nodeDetailsWithObjects:objects];
}

+ (NodeDetails*)createDirectoryWithResourcePath:(NSString*)resourcePath andAuthorizationDetails:(AuthorizationDetails*)authorizationDetails {
    return [NodeDetailsAdapter createNodeWithKind:@"directory" resourcePath:resourcePath andAuthorizationDetails:authorizationDetails];
}

+ (NodeDetails*)createNodeWithKind:(NSString*)kind resourcePath:(NSString*)resourcePath andAuthorizationDetails:(AuthorizationDetails*)authorizationDetails {
    
    NSString *url = [@"https://one.ubuntu.com/api/file_storage/v1" stringByAppendingString:resourcePath];
    NodeDetailsAdapter *adapter = [[NodeDetailsAdapter alloc] initWithUrl:url andAuthorizationDetails:authorizationDetails];
    
    NSMutableDictionary *requestObjects = [NSMutableDictionary dictionary];
    [requestObjects setObject:kind forKey:@"kind"];
    [requestObjects setObject:@"false" forKey:@"is_public"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestObjects options:0 error:&error];
    if (error) {
        NSLog(@"%s with error: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    NSMutableURLRequest *request = [adapter constructRequest];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = jsonData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *responseObjects = [adapter requestObjectsWithRequest:request];
    return [NodeDetails nodeDetailsWithObjects:responseObjects];
}
@end
