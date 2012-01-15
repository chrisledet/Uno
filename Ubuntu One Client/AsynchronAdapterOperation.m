#import "AsynchronAdapterOperation.h"

@interface AsynchronAdapterOperation (Private) <AsynchronAdapterDelegate>
@end

@implementation AsynchronAdapterOperation {
@private
    AsynchronAdapter *_adapter;
    BOOL _isDone;
}

- (id)initWithAsynchronAdapter:(AsynchronAdapter*)adapter {
    NSAssert(adapter, @"adapter must not be null.");

    self = [super init];
    if (self) {
        _adapter = adapter;
        _isDone = false;
        
        [_adapter addDelegate:self];
    }
    
    return self;
}

+ (AsynchronAdapterOperation*)adapterOperationWithAsynchronAdapter:(AsynchronAdapter*)adapter {
    return [[AsynchronAdapterOperation alloc] initWithAsynchronAdapter:adapter];
}

- (void)main {
    [_adapter request];
    while (!_isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

#pragma mark -
#pragma mark AsynchronAdapterDelegate
- (void)didReceiveData:(NSData*)data {
    // ...
}

- (void)didFailWithError:(NSError*)error {
    NSLog(@"AdapterOperation fail for %@.", _adapter.url);
    _isDone = YES;
}
- (void)didFinishLoading {
    NSLog(@"AdapterOperation done for %@.", _adapter.url);
    _isDone = YES;
}
@end