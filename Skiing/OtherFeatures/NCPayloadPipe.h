#import "NCSlopeFeatureContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface NCPayloadPipe : NSObject

+ (void)sendPath:(NSString *)path
      parameters:(NSDictionary *)parameters
      plainReply:(BOOL)plainReply
      completion:(NCSlopeDictionaryBlock)completion;

@end

NS_ASSUME_NONNULL_END
