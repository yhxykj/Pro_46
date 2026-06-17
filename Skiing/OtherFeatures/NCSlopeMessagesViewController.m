#import "NCSlopeMessagesViewController.h"

#import "NCAdjustEventReporter.h"

#import <AdjustSdk/AdjustSdk.h>

static NSString * const NCSlopeMessagesAdjustAppToken = @"token";

@implementation NCSlopeMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self nc_prepareAdjustForMessagesIfNeeded];
}

- (void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    [super didBecomeActiveWithConversation:conversation];

    [self nc_prepareAdjustForMessagesIfNeeded];
    [Adjust trackSubsessionStart];
}

- (void)willResignActiveWithConversation:(MSConversation *)conversation {
    [super willResignActiveWithConversation:conversation];

    [Adjust trackSubsessionEnd];
}

- (void)nc_prepareAdjustForMessagesIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ADJConfig *adjustConfig = [[ADJConfig alloc] initWithAppToken:NCSlopeMessagesAdjustAppToken
                                                          environment:ADJEnvironmentSandbox];
        [Adjust initSdk:adjustConfig];
        [NCAdjustEventReporter configureGlobalCallbackParameter];
    });
}

@end
