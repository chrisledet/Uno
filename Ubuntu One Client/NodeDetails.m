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

#import "NodeDetails.h"

@interface NodeDetails (Private)
+ (NSArray*)childrenNodesFromObjects:(NSArray*)childrenObjects;
+ (NSDate*)dateFromString:(NSString*)dateString;
@end

@implementation NodeDetails
@synthesize kind = _kind;
@synthesize contentPath = _contentPath;
@synthesize children = _children;
@synthesize path = _path;
@synthesize resourcePath = _resourcePath;
@synthesize whenChanged = _whenChanged;
@synthesize whenCreated = _whenCreated;
@synthesize hash = _hash;

+ (NodeDetails*)nodeDetailsWithObjects:(NSDictionary*)objects {
    NodeDetails *result = [[NodeDetails alloc] init];
    if (result) {
        result.kind = [objects objectForKey:@"kind"];
        result.contentPath = [objects objectForKey:@"content_path"];
        result.path = [objects objectForKey:@"path"];
        result.resourcePath = [objects objectForKey:@"resource_path"];
        result.hash = [objects objectForKey:@"hash"];

        NSString *whenChangedString = [objects objectForKey:@"when_changed"];
        result.whenChanged = [NodeDetails dateFromString:whenChangedString];

        NSString *whenCreatedString = [objects objectForKey:@"when_created"];
        result.whenCreated = [NodeDetails dateFromString:whenCreatedString];
        
        NSArray *children = [objects objectForKey:@"children"];
        if (children) {
            result.children = [NodeDetails childrenNodesFromObjects:children];
        }
    }

    return result;
}

+ (NSArray*)childrenNodesFromObjects:(NSArray*)childrenObjects {
    NSMutableArray *result = [NSMutableArray array];
    [childrenObjects enumerateObjectsUsingBlock:^(NSDictionary *objects, NSUInteger i, BOOL *stop) {
        NodeDetails *nodeDetails = [NodeDetails nodeDetailsWithObjects:objects];
        [result addObject:nodeDetails];
    }];
    
    return result;
}

+ (NSDate*)dateFromString:(NSString*)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    
    return [dateFormatter dateFromString:dateString];
}

- (NSString*)description{
    NSMutableString *childrenDescription = [NSMutableString stringWithString:@""];
    if (self.children) {
        [childrenDescription appendString:@"["];
        [self.children enumerateObjectsUsingBlock:^(NodeDetails *child, NSUInteger idx, BOOL *stop) {
            [childrenDescription appendFormat:@"%ld=%@; ", idx, child];
        }];
        [childrenDescription appendString:@"]"];
    }

    return [NSString stringWithFormat:@"NodeDetails: [kind=%@; contentPath=%@; path=%@; resourcePath=%@; whenCreated=%@; whenChanged=%@; children=%@]", self.kind, self.contentPath, self.path, self.resourcePath, self.whenCreated, self.whenChanged, childrenDescription];
}

@end
