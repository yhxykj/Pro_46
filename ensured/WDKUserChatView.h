
#import <UIKit/UIKit.h>

#import "LRangeObject.h"
#import "IEditObject.h"


NS_ASSUME_NONNULL_BEGIN

@interface WDKUserChatView : UIView
@property (nonatomic, strong) UITableView *  textStoreTableView;
@property (nonatomic, copy) NSDictionary *  moderationSecureTap;
@property (nonatomic, strong) UIView *  sceneGestureInitialView;
@property (nonatomic, strong) UIScrollView *  cellPriceActiveScrollView;



-(UILabel *)chatInputScroll;

-(UILabel *)sendLikeMore:(double)settingsFeatured register_tvField:(BOOL)register_tvField starNames:(long)starNames;

-(long)disappearKeyboardData:(NSString *)indicatorPrompt;

@end

NS_ASSUME_NONNULL_END
