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

#import "SyncWorker.h"
#import "UserDetailsAdapter.h"
#import "NodeDetailsAdapter.h"
#import "ContentAdapter.h"
#import "AsynchronAdapterOperation.h"
#import "ContentUploadAdapter.h"
#import "FileWritingAsynchronAdapterDelegate.h"
#import "FileAttributesUpdatingAsynchronAdapterDelegate.h"

@interface SyncWorker (Private)
- (void)syncRemoteDirectoryRecursively:(NSString*)resourcePath;
- (void)syncRemoteFile:(NodeDetails*)nodeDetails withRemoteDirectory:(NodeDetails*)parentNodeDetails;
@end

@interface SyncWorker (DirectoryHandler)
- (void)createLocalDirectory:(NSString*)absolutePath;
- (void)createRemoteDirectory:(NSString*)resourcePath;
@end

@interface SyncWorker (FileHandler)
- (void)download:(NodeDetails*)nodeDetails to:(NSString*)absolutePath;
- (void)upload:(NSString*)absolutePath toDirectory:(NodeDetails*)nodeDetails;
@end

@implementation SyncWorker {
@private
    NSString *_absoluteRootPath;
    AuthorizationDetails *_authorizationDetails;
    NSOperationQueue *_operationQueue;
}

+ (void)syncWithAbsoluteRootPath:(NSString*)path andAuthorizationDetails:(AuthorizationDetails*)authorizationDetails {
    SyncWorker *worker = [[SyncWorker alloc] initWithAbsoluteRootPath:path andAuthorizationDetails:authorizationDetails];

    // [worker sync];
    [worker performSelectorInBackground:@selector(sync) withObject:nil];
}


#pragma mark -
#pragma mark initialization methods
- (id)initWithAbsoluteRootPath:(NSString*)path andAuthorizationDetails:(AuthorizationDetails*)authorizationDetails {
    self = [super init];
    if (self) {
        _absoluteRootPath = path;
        _authorizationDetails = authorizationDetails;
        
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 3;
    }

    return self;
}

#pragma mark -
#pragma mark other methods
- (void)sync {
    UserDetails *userDetails = [UserDetailsAdapter requestWithAuthorizationDetails:_authorizationDetails];
    [self syncRemoteDirectoryRecursively:userDetails.rootNodePath];
}

- (void)syncRemoteDirectoryRecursively:(NSString*)resourcePath {
    NodeDetails *nodeDetails = [NodeDetailsAdapter requestNodePath:resourcePath withAuthorizationDetails:_authorizationDetails andIncludingChildren:YES];
    
    NSString *absoluteLocalPath = [_absoluteRootPath stringByAppendingPathComponent:nodeDetails.path];
    [self createLocalDirectory:absoluteLocalPath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSMutableArray *files = [NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:absoluteLocalPath error:&error]];
    if (error) {
        NSLog(@"%s with error: %@", __PRETTY_FUNCTION__, error);
    }
    
    // iterate over remote files
    [nodeDetails.children enumerateObjectsUsingBlock:^(NodeDetails *childNodeDetails, NSUInteger idx, BOOL *stop) {
        NSString *filename = childNodeDetails.path.lastPathComponent;
        [files removeObject:filename];

        if ([childNodeDetails.kind isEqualToString:@"directory"]) {
            [self syncRemoteDirectoryRecursively:childNodeDetails.resourcePath];
        } else if ([childNodeDetails.kind isEqualToString:@"file"]) {
            [self syncRemoteFile:childNodeDetails withRemoteDirectory:nodeDetails];
        }
    }];

    // iterate over new local files
    [files enumerateObjectsUsingBlock:^(NSString *file, NSUInteger idx, BOOL *stop) {
        if ([file hasPrefix:@"."]) {
            NSLog(@"ignoring %@", file);
            return;
        }
        
        NSString *absolutePathToFile = [absoluteLocalPath stringByAppendingPathComponent:file];
        BOOL isDirectory = NO;
        BOOL fileExists = [fileManager fileExistsAtPath:absolutePathToFile isDirectory:&isDirectory];
        NSAssert(fileExists, @"absolutePathToFile not found.");
        
        if (isDirectory) {
            NSString *newResourcePath = [resourcePath stringByAppendingPathComponent:file];
            [self createRemoteDirectory:newResourcePath];
            [self syncRemoteDirectoryRecursively:newResourcePath];
        } else {
            [self upload:absolutePathToFile toDirectory:nodeDetails];
        }
    }]; 
}

- (void)syncRemoteFile:(NodeDetails*)nodeDetails withRemoteDirectory:(NodeDetails*)parentNodeDetails {
    NSAssert(nodeDetails, @"nodeDetails must not be null.");
    NSAssert(parentNodeDetails, @"parentNodeDetails must not be null.");
    
    NSString *absolutePath = [_absoluteRootPath stringByAppendingPathComponent:nodeDetails.path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory = NO;
    BOOL fileExists = [fileManager fileExistsAtPath:absolutePath isDirectory:&isDirectory];
    NSAssert(!isDirectory, @"must be a file, not a directory.");
    
    if (fileExists) {
        NSError *error = nil;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:absolutePath error:&error];
        if (error) {
            NSLog(@"%s with error: %@", __PRETTY_FUNCTION__, error);
            return;
        }
        
        NSDate *whenChangedLocal = [attributes objectForKey:NSFileModificationDate];
        NSDate *whenChangedRemote = nodeDetails.whenChanged;
        
        if ([whenChangedLocal isLessThan:whenChangedRemote]) {
            [self download:nodeDetails to:absolutePath];
        } else if ([whenChangedLocal isGreaterThan:whenChangedRemote]) {
            [self upload:absolutePath toDirectory:parentNodeDetails];
        }
    } else {
        [self download:nodeDetails to:absolutePath];
    }
}

#pragma mark -
#pragma mark DirectoryHandler
- (void)createLocalDirectory:(NSString*)absolutePath {
    NSAssert(absolutePath, @"absolutePath must not be null.");

    NSFileManager *fileManager = [NSFileManager defaultManager];    
    if ([fileManager fileExistsAtPath:absolutePath]) {
        return;
    }
    
    NSError *error = nil;
    [fileManager createDirectoryAtPath:absolutePath withIntermediateDirectories:NO attributes:nil error:&error];
    if (error) {
        NSLog(@"%s failed with error: %@", __PRETTY_FUNCTION__, error);
    }
}

- (void)createRemoteDirectory:(NSString*)resourcePath {
    NSAssert(resourcePath, @"resourcePath must not be null.");
    [NodeDetailsAdapter createDirectoryWithResourcePath:resourcePath andAuthorizationDetails:_authorizationDetails];
}

#pragma mark -
#pragma mark FileHandler
- (void)download:(NodeDetails*)nodeDetails to:(NSString*)absolutePath {
    NSAssert(absolutePath, @"absolutePath must not be null.");
    NSAssert(nodeDetails, @"nodeDetails must not be null.");
    
    NSLog(@"downloading \"%@\" to \"%@\"", nodeDetails.resourcePath, absolutePath);

    FileWritingAsynchronAdapterDelegate *fileWritingDelegate = [[FileWritingAsynchronAdapterDelegate alloc] initWithAbsolutePath:absolutePath andNodeDetails:nodeDetails];
    NSArray *delegates = [NSArray arrayWithObject:fileWritingDelegate];
    AsynchronAdapter *adapter = [ContentAdapter adapterWithContentPath:nodeDetails.contentPath authorizationDetails:_authorizationDetails andDelegates:delegates];
    NSOperation *operation = [AsynchronAdapterOperation adapterOperationWithAsynchronAdapter:adapter];
    [_operationQueue addOperation:operation];
}

- (void)upload:(NSString*)absolutePath toDirectory:(NodeDetails*)nodeDetails {
    NSAssert(absolutePath, @"absolutePath must not be null.");
    NSAssert(nodeDetails, @"nodeDetails must not be null.");
    
    NSLog(@"uploading \"%@\" to \"%@\"", absolutePath, nodeDetails.resourcePath);
    
    FileAttributesUpdatingAsynchronAdapterDelegate *delegate = [[FileAttributesUpdatingAsynchronAdapterDelegate alloc] initWithAbsolutePath:absolutePath];    
    
    ContentUploadAdapter *adapter = [ContentUploadAdapter adapterWithAbsolutePath:absolutePath directoryContentPath:nodeDetails.contentPath authorizationDetails:_authorizationDetails andDelegates:[NSArray arrayWithObject:delegate]];
    
    NSOperation *operation = [AsynchronAdapterOperation adapterOperationWithAsynchronAdapter:adapter];
    [_operationQueue addOperation:operation];
}
@end
