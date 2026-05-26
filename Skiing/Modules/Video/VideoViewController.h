//
//  VideoViewController.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoViewController : UIViewController
@property (nonatomic, copy, nullable) NSString *initialVideoFileName;
@property (nonatomic, copy, nullable) NSArray<NSString *> *videoFileNames;
@property (nonatomic, assign) BOOL showsBackButton;
@end

NS_ASSUME_NONNULL_END
