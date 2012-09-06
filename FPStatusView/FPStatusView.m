//
//  FPStatusView.m
//  FPStatusViewDemo
//
//  Created by Arnaud de Mouhy on 28/08/12.
//  Copyright (c) 2012 Flying Pingu. All rights reserved.
//

#import "FPStatusView.h"

@implementation FPStatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _statusFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
        _buttonFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        _maxSize = CGSizeMake(600, 100);
        _buttonArray = [[NSMutableArray alloc] init];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        self.backgroundColor = [UIColor blackColor];
        self.layer.cornerRadius = 10.0f;
        self.clipsToBounds = YES;
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator.center = CGPointMake(22, 22);
        _activityIndicator.hidesWhenStopped = YES;
        //_activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
        
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 21, 21)];
        //_iconView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        _iconView.alpha = 0.0;
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textColor = [UIColor whiteColor];
        //_statusLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        [self addSubview:_activityIndicator];
        [self addSubview:_iconView];
        [self addSubview:_statusLabel];
        
    }
    
    return self;
}

- (void)setStatusWithText:(NSString *)text andStatusIcon:(FPStatusIcon)icon
{
    [self setStatusWithText:text andStatusIcon:icon andButtonTitles:nil];
}

- (void)setStatusWithText:(NSString *)text andStatusIcon:(FPStatusIcon)icon andButtonTitles:(NSString *)buttonTitle, ...
{
    NSMutableArray *newButtonArray = [[NSMutableArray alloc] init];
    
    va_list args;
    va_start(args, buttonTitle);
    NSInteger tagI = 0;
    for (NSString *arg = buttonTitle; arg != nil; arg = va_arg(args, NSString *)) {
        UIButton *newButton = [[UIButton alloc] init];
        [newButton setTitle:arg forState:UIControlStateNormal];
        [newButton setBackgroundColor:[UIColor whiteColor]];
        [[newButton titleLabel] setFont:_buttonFont];
        [newButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        newButton.layer.cornerRadius = 5.0f;
        newButton.tag = tagI;
        [newButton addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        
        tagI++;
        
        [newButtonArray addObject:newButton];
        [newButton release];
    }
    va_end(args);
    
    NSInteger newButtonCount = [newButtonArray count];
    
    _maxSize = CGSizeMake(self.superview.bounds.size.width - (12 + _iconView.bounds.size.width + 12), self.superview.bounds.size.height);
    
    CGSize newStatusLabelSize = [text sizeWithFont:_statusFont constrainedToSize:_maxSize lineBreakMode:UILineBreakModeWordWrap];
    CGSize newStatusViewSize = CGSizeMake(newStatusLabelSize.width, newStatusLabelSize.height + newButtonCount * 44);
    
    CGSize oldStatusLabelSize = _statusLabel.bounds.size;
    //CGSize oldStatusViewSize = CGSizeMake(oldStatusLabelSize.width, oldStatusLabelSize.height + newButtonCount * 44);
    CGSize oldStatusViewSize = self.bounds.size;
    
    CGFloat diffWidth = newStatusViewSize.width - newStatusViewSize.width;
    CGFloat diffHeight = oldStatusViewSize.height - oldStatusViewSize.height;
    
    // Mise à jour des propriétés du label
    _statusLabel.font = _statusFont;
    
    if (diffWidth >= 0 || diffHeight >= 0) { // nouveau status plus large ou plus haut;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            // on agrandit
            [self resizeStatusViewWithLabelSize:newStatusLabelSize andButtonCount:newButtonCount];
            // on fait disparaitre
            [self makeStatusLabelDisappearWithSize:oldStatusLabelSize];
        } completion:^(BOOL finished) {
            for (UIButton *button in _buttonArray) {
                [button removeFromSuperview];
            }
            [_buttonArray removeAllObjects];
            _buttonArray = newButtonArray;
            // puis on fait apparaitre
            _statusLabel.text = text;
            [self prepareStatusLabelToAppearWithSize:newStatusLabelSize];
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self makeStatusLabelAppearWithSize:newStatusLabelSize];
            } completion:nil];
        }];
        
    } else {
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            // on fait disparaitre
            [self makeStatusLabelDisappearWithSize:oldStatusLabelSize];
        } completion:^(BOOL finished) {
            for (UIButton *button in _buttonArray) {
                [button removeFromSuperview];
            }
            [_buttonArray removeAllObjects];
            _buttonArray = newButtonArray;
            _statusLabel.text = text;
            // puis on fait apparaitre + on rétrécit
            [self prepareStatusLabelToAppearWithSize:newStatusLabelSize];
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self resizeStatusViewWithLabelSize:newStatusLabelSize andButtonCount:newButtonCount];
                [self makeStatusLabelAppearWithSize:newStatusLabelSize];
            } completion:nil];
        }];
        
    }
    
    UIImage *iconImage = nil;
    switch (icon) {
        case FPStatusError:
            iconImage = [UIImage imageNamed:@"videotchat-error"];
            break;
        case FPStatusRinging:
            iconImage = [UIImage imageNamed:@"videotchat-ringing"];
            break;
        case FPStatusHungUp:
            iconImage = [UIImage imageNamed:@"videotchat-hungup"];
            break;
        case FPStatusCalling:
            iconImage = [UIImage imageNamed:@"videotchat-calling"];
            break;
        default:
            break;
    }
    
    if (!iconImage) {
        [self setStatusIconWithActivityIndicator];
    } else {
        [self setStatusIconWithImage:iconImage];
    }
}

- (void)setStatusIconWithImage:(UIImage *)image
{
    [_activityIndicator stopAnimating];
    
    _iconView.image = image;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _iconView.alpha = 1.0f;
    } completion:nil];
}

- (void)setStatusIconWithActivityIndicator
{
    [_activityIndicator startAnimating];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _iconView.alpha = 0.0f;
    } completion:nil];
}

- (void)makeStatusLabelDisappearWithSize:(CGSize)size
{
    _statusLabel.frame = CGRectMake(CGRectGetMaxX(_iconView.frame) + 12, 12, size.width, size.height);
    CATransform3D _3Dt = CATransform3DMakeRotation(-M_PI_2, 1.0, 0.0, 0.0);
    _statusLabel.layer.shouldRasterize = TRUE;
    _statusLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    _statusLabel.layer.transform = _3Dt;
    
    for (UIButton *button in _buttonArray) {
        button.alpha = 0.0f;
    }
}

- (void)prepareStatusLabelToAppearWithSize:(CGSize)size
{
    CATransform3D _3Dt = CATransform3DMakeRotation(-M_PI_2, 1.0, 0.0, 0.0);
    _statusLabel.layer.shouldRasterize = TRUE;
    _statusLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    _statusLabel.layer.transform = _3Dt;
    [_statusLabel sizeToFit];
    CGRect statusLabelTmpFrame = _statusLabel.frame;
    statusLabelTmpFrame.origin.x = CGRectGetMaxX(_iconView.frame) + 12;
    statusLabelTmpFrame.origin.y = 12;
    _statusLabel.frame = statusLabelTmpFrame;
    //_statusLabel.backgroundColor = [UIColor redColor];
    _statusLabel.numberOfLines = 0;
    
    for (UIButton *button in _buttonArray) {
        button.alpha = 0.0f;
        
        CGSize textSize = [[button titleForState:UIControlStateNormal] sizeWithFont:_buttonFont constrainedToSize:_maxSize lineBreakMode:UILineBreakModeTailTruncation];
        button.bounds = CGRectMake(0, 0, 12 + textSize.width + 12, 8 + textSize.height + 8);
        button.center = CGPointMake(self.bounds.size.width/2, 12 + size.height + 12 + button.bounds.size.height/2 + [_buttonArray indexOfObject:button] * (button.bounds.size.height + 12));
        [self addSubview:button];
    }
}

- (void)makeStatusLabelAppearWithSize:(CGSize)size
{
    _statusLabel.frame = CGRectMake(CGRectGetMaxX(_iconView.frame) + 12, 12, size.width, size.height);
    CATransform3D _3Dt = CATransform3DMakeRotation(0, 1.0, 0.0, 0.0);
    _statusLabel.layer.shouldRasterize = TRUE;
    _statusLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    _statusLabel.layer.transform = _3Dt;
    
    for (UIButton *button in _buttonArray) {
        button.alpha = 1.0f;
    }
}

- (void)resizeStatusViewWithLabelSize:(CGSize)size andButtonCount:(NSInteger)buttonCount
{
    self.bounds = CGRectMake(0, 0, CGRectGetMaxX(_iconView.frame) + 12 + size.width + 12, 12 + size.height + 0 + buttonCount * (44 + 12));
}

- (void)clickedButton:(id)sender
{
    NSLog(@"clickedButton with tag: %i", [(UIButton *)sender tag]);
    
    if ([_delegate respondsToSelector:@selector(statusView:clickedButtonAtIndex:)]) {
        [_delegate statusView:self clickedButtonAtIndex:[(UIButton *)sender tag]];
    }
}

- (void)dealloc
{
    [_buttonArray removeAllObjects];
    [_buttonArray release];
    
    [_statusFont release];
    
    [_statusLabel release];
    [_iconView release];
    [_activityIndicator release];
    [super dealloc];
}

@end

#import <objc/runtime.h>

@implementation UIView (FPStatusView)

static char UIViewStatusView;

@dynamic statusView;

- (void)showFPStatusViewAtCenterWithText:(NSString *)text andStatusIcon:(FPStatusIcon)icon
{
    self.statusView.center = self.center;
    [self.statusView setStatusWithText:text andStatusIcon:icon];
    
    [self addSubview:self.statusView];
}

- (void)showFPStatusViewFromBottomWithText:(NSString *)text andStatusIcon:(FPStatusIcon)icon
{
    NSLog(@"TODOOOOOOOOO");
}

- (void)dismissFPStatusView
{
    [self.statusView removeFromSuperview];
}

- (void)setStatusView:(FPStatusView *)statusView
{
    [self willChangeValueForKey:@"statusView"];
    objc_setAssociatedObject(self, &UIViewStatusView,
                             statusView,
                             OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"statusView"];
}

- (FPStatusView *)statusView
{
    FPStatusView *statusView = objc_getAssociatedObject(self, &UIViewStatusView);
    if(!statusView) {
        statusView = [[FPStatusView alloc] initWithFrame:CGRectZero];
        self.statusView = statusView;
    }
    return statusView;
}

@end
