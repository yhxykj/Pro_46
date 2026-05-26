//
//  MineVideoPlayerViewController.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MineVideoPlayerViewController : UIViewController

@property (nonatomic, copy) NSString *videoFileName;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatarName;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *likeCount;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSString *viewCount;

@end

NS_ASSUME_NONNULL_END
