#import <Foundation/Foundation.h>
#import "AsynchronAdapter.h"

@interface AsynchronAdapterOperation : NSOperation
+ (AsynchronAdapterOperation*)adapterOperationWithAsynchronAdapter:(AsynchronAdapter*)adapter;
@end
