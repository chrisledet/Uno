#import <Foundation/Foundation.h>
#import "AsynchronousAdapter.h"

@interface AsynchronousAdapterOperation : NSOperation <AsynchronousAdapterDelegate>
+ (AsynchronousAdapterOperation*)adapterOperationWithAsynchronousAdapter:(AsynchronousAdapter*)adapter;
@end
