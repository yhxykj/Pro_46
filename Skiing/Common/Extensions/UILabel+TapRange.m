//
//  UILabel+TapRange.m
//  Skiing
//

#import "UILabel+TapRange.h"
#import "DesignTokens.h"

@implementation UILabel (TapRange)

- (BOOL)didTapRange:(NSRange)range inGesture:(UITapGestureRecognizer *)gesture {
    if (!self.attributedText) return NO;

    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    NSTextStorage   *textStorage   = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];

    textContainer.lineFragmentPadding  = 0;
    textContainer.maximumNumberOfLines = self.numberOfLines;
    textContainer.lineBreakMode        = self.lineBreakMode;
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];

    CGPoint location  = [gesture locationInView:self];
    NSUInteger charIndex = [layoutManager characterIndexForPoint:location
                                                inTextContainer:textContainer
                       fractionOfDistanceBetweenInsertionPoints:nil];
    return NSLocationInRange(charIndex, range);
}

@end

@implementation NSMutableAttributedString (Link)

- (NSRange)addLinkToSubstring:(NSString *)substring color:(UIColor *)color {
    UIColor *linkColor = color ?: [DesignColors linkColor];
    NSRange range = [self.string rangeOfString:substring];
    if (range.location != NSNotFound) {
        [self addAttributes:@{
            NSForegroundColorAttributeName: linkColor,
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
        } range:range];
    }
    return range;
}

@end
