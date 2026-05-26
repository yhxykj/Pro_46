//
//  ProfileRelationshipListViewController.h
//  Skiing
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ProfileRelationshipListMode) {
    ProfileRelationshipListModeMessage,
    ProfileRelationshipListModeBlacklist
};

@interface ProfileRelationshipListViewController : UIViewController

+ (NSInteger)relationshipItemCountForTitle:(NSString *)title mode:(ProfileRelationshipListMode)mode;

- (instancetype)initWithTitle:(NSString *)title mode:(ProfileRelationshipListMode)mode;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
