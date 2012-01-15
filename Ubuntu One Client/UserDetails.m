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

#import "UserDetails.h"

@implementation UserDetails
@synthesize name = _name;
@synthesize bytesInUse = _bytesInUse;
@synthesize bytesAvailable = _bytesAvailable;
@synthesize rootNodePath = _rootNodePath;

+ (UserDetails*)userDetailsWithObjects:(NSDictionary*)objects {
    UserDetails *result = [[UserDetails alloc] init]; 
    result.name = [objects objectForKey:@"visible_name"];
    result.bytesAvailable = [objects objectForKey:@"max_bytes"];
    result.bytesInUse = [objects objectForKey:@"used_bytes"];
    result.rootNodePath = [objects objectForKey:@"root_node_path"]; 
    
    return result;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"UserDetails: [name=%@; bytesAvailable=%@; bytesInUse=%@; rootNodePath=%@;]", self.name, self.bytesAvailable, self.bytesInUse, self.rootNodePath];
}

@end
