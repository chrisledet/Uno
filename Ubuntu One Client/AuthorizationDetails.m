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

#import "AuthorizationDetails.h"
#import "NSFileManager+ApplicationSupportDirectory.h"

@implementation AuthorizationDetails
static AuthorizationDetails *currentInstance = nil;

#pragma mark -
#pragma mark propertites
@synthesize consumerKey;
@synthesize consumerSecret;
@synthesize token;
@synthesize tokenSecret;
@synthesize username;
@synthesize password;

#pragma mark -
#pragma mark initialization methods
+ (AuthorizationDetails*)authorizationDetailsWithObjects:(NSDictionary*)objects {
    AuthorizationDetails *result = [[AuthorizationDetails alloc] init];
    result.consumerKey = [objects valueForKey:@"consumer_key"];
    result.consumerSecret = [objects valueForKey:@"consumer_secret"];
    result.token = [objects valueForKey:@"token"];
    result.tokenSecret = [objects valueForKey:@"token_secret"];
    
    return result;
}

#pragma mark -
#pragma mark handle application support data
+ (AuthorizationDetails*)readFromApplicationSupportDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *thisApplicationSupportDirectory = [fileManager currentApplicationSupportDirectoryCreateIfNecessary:YES];
    NSString *tokenArchivePath = [thisApplicationSupportDirectory stringByAppendingPathComponent:@"token.archive"];

    return [NSKeyedUnarchiver unarchiveObjectWithFile:tokenArchivePath];
}

- (void)writeToApplicationSupportDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *thisApplicationSupportDirectory = [fileManager currentApplicationSupportDirectoryCreateIfNecessary:YES];
    NSString *tokenArchivePath = [thisApplicationSupportDirectory stringByAppendingPathComponent:@"token.archive"];
    
    currentInstance = self;
    [NSKeyedArchiver archiveRootObject:self toFile:tokenArchivePath];
}

#pragma mark -
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.consumerKey = [decoder decodeObjectForKey:@"consumerKey"];
        self.consumerSecret = [decoder decodeObjectForKey:@"consumerSecret"];
        self.token = [decoder decodeObjectForKey:@"token"];
        self.tokenSecret = [decoder decodeObjectForKey:@"tokenSecret"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.consumerKey forKey:@"consumerKey"];
    [encoder encodeObject:self.consumerSecret forKey:@"consumerSecret"];
    [encoder encodeObject:self.token forKey:@"token"];
    [encoder encodeObject:self.tokenSecret forKey:@"tokenSecret"];
}

#pragma mark -
#pragma mark other methods
+ (AuthorizationDetails*)current {
    if (!currentInstance) {
        currentInstance = [AuthorizationDetails readFromApplicationSupportDirectory];
    }

    return currentInstance;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"AuthorizationDetails=[consumerKey=%@; token=%@]", self.consumerKey, self.token];
}

@end
