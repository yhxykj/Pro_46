#import "NCLaunchCoverController.h"

#import "NCSlopeFeatureContext.h"

@implementation NCLaunchCoverController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NCSlopeRouteLaunchImage]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];

    [NSLayoutConstraint activateConstraints:@[
        [imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
}

@end
