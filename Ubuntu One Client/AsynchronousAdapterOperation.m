#import "AsynchronousAdapterOperation.h"

@interface AsynchronousAdapterOperation (Private) <AsynchronousAdapterDelegate>
@end

@implementation AsynchronousAdapterOperation {
@private
    AsynchronousAdapter *_adapter;
    BOOL _isDone;
}

- (id)initWithAsynchronousAdapter:(AsynchronousAdapter*)adapter {
    NSAssert(adapter, @"adapter must not be null.");

    self = [super init];
    if (self) {
        _adapter = adapter;
        _isDone = false;
        
        [_adapter addDelegate:self];
    }
    
    return self;
}

+ (AsynchronousAdapterOperation*)adapterOperationWithAsynchronousAdapter:(AsynchronousAdapter*)adapter {
    return [[AsynchronousAdapterOperation alloc] initWithAsynchronousAdapter:adapter];
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