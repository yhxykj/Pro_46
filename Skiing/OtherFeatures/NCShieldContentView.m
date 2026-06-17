#import "NCShieldContentView.h"

@interface NCSilentTextField : UITextField
@end

@implementation NCShieldContentView {
    NCSilentTextField *_secureTextField;
    UIView *_innerContentView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupShieldView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupShieldView];
    }
    return self;
}

- (UIView *)innerContentView {
    return _innerContentView;
}

- (void)setupShieldView {
    self.backgroundColor = UIColor.clearColor;
    _innerContentView = [[UIView alloc] init];

    _secureTextField = [[NCSilentTextField alloc] init];
    _secureTextField.secureTextEntry = YES;
    _secureTextField.backgroundColor = UIColor.clearColor;
    _secureTextField.textColor = UIColor.clearColor;
    _secureTextField.tintColor = UIColor.clearColor;
    _secureTextField.borderStyle = UITextBorderStyleNone;
    _secureTextField.clipsToBounds = YES;
    [self addSubview:_secureTextField];
    [self pinChild:_secureTextField toParent:self];

    UIView *canvasView = [self findSecureCanvasInside:_secureTextField];
    UIView *targetView = canvasView ?: self;
    targetView.backgroundColor = UIColor.clearColor;
    targetView.userInteractionEnabled = YES;
    targetView.clipsToBounds = YES;
    [targetView addSubview:_innerContentView];
    [self pinChild:_innerContentView toParent:targetView];
}

- (UIView *)findSecureCanvasInside:(UIView *)view {
    for (UIView *subview in view.subviews) {
        NSString *className = NSStringFromClass(subview.class);
        if ([className containsString:@"CanvasView"] ||
            [className containsString:@"LayoutCanvasView"] ||
            [className containsString:@"TextLayoutCanvasView"]) {
            return subview;
        }

        UIView *nested = [self findSecureCanvasInside:subview];
        if (nested) {
            return nested;
        }
    }
    return nil;
}

- (void)pinChild:(UIView *)child toParent:(UIView *)parent {
    child.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [child.leadingAnchor constraintEqualToAnchor:parent.leadingAnchor],
        [child.trailingAnchor constraintEqualToAnchor:parent.trailingAnchor],
        [child.topAnchor constraintEqualToAnchor:parent.topAnchor],
        [child.bottomAnchor constraintEqualToAnchor:parent.bottomAnchor]
    ]];
}

@end

@implementation NCSilentTextField

- (BOOL)canBecomeFirstResponder {
    return NO;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    return CGRectZero;
}

- (NSArray<UITextSelectionRect *> *)selectionRectsForRange:(UITextRange *)range {
    return @[];
}

@end
