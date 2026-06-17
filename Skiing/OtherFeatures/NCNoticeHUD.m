#import "NCNoticeHUD.h"

#import "NCSlopeGatewayInternal.h"

@interface NCNoticeHUD ()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) NSUInteger loadingToken;
@end

@implementation NCNoticeHUD

+ (instancetype)sharedHUD {
    static NCNoticeHUD *hud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[NCNoticeHUD alloc] init];
    });
    return hud;
}

+ (void)showLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NCNoticeHUD sharedHUD] showLoadingOnWindow:[NCSlopeGateway sharedGateway].overlayWindow];
    });
}

- (void)showLoadingOnWindow:(UIWindow *)window {
    if (!window) {
        return;
    }

    self.loadingToken += 1;
    if (self.indicatorView && self.containerView.superview == window) {
        self.containerView.frame = window.bounds;
        self.indicatorView.center = CGPointMake(CGRectGetMidX(self.containerView.bounds), CGRectGetMidY(self.containerView.bounds));
        [self.indicatorView startAnimating];
        [window bringSubviewToFront:self.containerView];
        return;
    }

    [self.containerView removeFromSuperview];
    self.containerView = nil;
    self.indicatorView = nil;

    UIView *container = [[UIView alloc] initWithFrame:window.bounds];
    container.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.2];
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [window addSubview:container];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    indicator.color = UIColor.whiteColor;
    indicator.center = container.center;
    [indicator startAnimating];
    [container addSubview:indicator];
    [window bringSubviewToFront:container];

    self.containerView = container;
    self.indicatorView = indicator;
}

+ (void)hideLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        NCNoticeHUD *hud = [NCNoticeHUD sharedHUD];
        NSUInteger token = hud.loadingToken;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (hud.loadingToken != token) {
                return;
            }
            [hud.indicatorView stopAnimating];
            [hud.containerView removeFromSuperview];
            hud.indicatorView = nil;
            hud.containerView = nil;
        });
    });
}

+ (void)showText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) {
                continue;
            }
            for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
                if (candidate.isKeyWindow) {
                    window = candidate;
                    break;
                }
            }
            if (window) {
                break;
            }
        }
        if (!window) {
            return;
        }

        UIView *toastView = [[UIView alloc] init];
        toastView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
        toastView.layer.cornerRadius = 12;
        toastView.clipsToBounds = YES;

        UILabel *label = [[UILabel alloc] init];
        label.text = text ?: @"";
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;

        [toastView addSubview:label];
        [window addSubview:toastView];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        toastView.translatesAutoresizingMaskIntoConstraints = NO;

        [NSLayoutConstraint activateConstraints:@[
            [label.topAnchor constraintEqualToAnchor:toastView.topAnchor constant:12],
            [label.bottomAnchor constraintEqualToAnchor:toastView.bottomAnchor constant:-12],
            [label.leadingAnchor constraintEqualToAnchor:toastView.leadingAnchor constant:16],
            [label.trailingAnchor constraintEqualToAnchor:toastView.trailingAnchor constant:-16],
            [toastView.centerXAnchor constraintEqualToAnchor:window.centerXAnchor],
            [toastView.centerYAnchor constraintEqualToAnchor:window.centerYAnchor],
            [toastView.leadingAnchor constraintGreaterThanOrEqualToAnchor:window.leadingAnchor constant:40],
            [toastView.trailingAnchor constraintLessThanOrEqualToAnchor:window.trailingAnchor constant:-40]
        ]];

        toastView.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            toastView.alpha = 1;
        }];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                toastView.alpha = 0;
            } completion:^(BOOL finished) {
                [toastView removeFromSuperview];
            }];
        });
    });
}

@end
