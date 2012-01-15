#import <Foundation/Foundation.h>
#import "AsynchronousAdapter.h"

@interface AsynchronousAdapterOperation : NSOperation
+ (AsynchronousAdapterOperation*)adapterOperationWithAsynchronousAdapter:(AsynchronousAdapter*)adapter;
@end
