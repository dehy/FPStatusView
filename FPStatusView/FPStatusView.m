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
        
        self.statusFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
        self.buttonFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        self.maxSize = CGSizeMake(600, 100);
        self.buttonArray = [[NSMutableArray alloc] init];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        self.backgroundColor = [UIColor blackColor];
        self.layer.cornerRadius = 10.0f;
        self.clipsToBounds = YES;
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activityIndicator.center = CGPointMake(22, 22);
        self.activityIndicator.hidesWhenStopped = YES;
        //self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 21, 21)];
        //self.iconView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        self.iconView.alpha = 0.0;
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.statusLabel.backgroundColor = [UIColor clearColor];
        self.statusLabel.textColor = [UIColor whiteColor];
        //self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        [self addSubview:self.activityIndicator];
        [self addSubview:self.iconView];
        [self addSubview:self.statusLabel];
        
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
        [[newButton titleLabel] setFont:self.buttonFont];
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
    
    self.maxSize = CGSizeMake(self.superview.bounds.size.width - (12 + self.iconView.bounds.size.width + 12), self.superview.bounds.size.height);
    CWLogDebug(@"Superview frame: %@", NSStringFromCGRect(self.superview.frame));
    CWLogDebug(@"FPStatusView MaxSize : %@", NSStringFromCGSize(self.maxSize));
    
    CGSize newStatusLabelSize = [text sizeWithFont:self.statusFont constrainedToSize:self.maxSize lineBreakMode:UILineBreakModeWordWrap];
    CGSize newStatusViewSize = CGSizeMake(newStatusLabelSize.width, newStatusLabelSize.height + newButtonCount * 44);
    
    CGSize oldStatusLabelSize = self.statusLabel.bounds.size;
    //CGSize oldStatusViewSize = CGSizeMake(oldStatusLabelSize.width, oldStatusLabelSize.height + newButtonCount * 44);
    CGSize oldStatusViewSize = self.bounds.size;
    
    CGFloat diffWidth = newStatusViewSize.width - newStatusViewSize.width;
    CGFloat diffHeight = oldStatusViewSize.height - oldStatusViewSize.height;
    
    // Mise à jour des propriétés du label
    self.statusLabel.font = self.statusFont;
    
    if (diffWidth >= 0 || diffHeight >= 0) { // nouveau status plus large ou plus haut;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            // on agrandit
            [self resizeStatusViewWithLabelSize:newStatusLabelSize andButtonCount:newButtonCount];
            // on fait disparaitre
            [self makeStatusLabelDisappearWithSize:oldStatusLabelSize];
        } completion:^(BOOL finished) {
            for (UIButton *button in self.buttonArray) {
                [button removeFromSuperview];
            }
            [self.buttonArray removeAllObjects];
            self.buttonArray = newButtonArray;
            // puis on fait apparaitre
            self.statusLabel.text = text;
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
            for (UIButton *button in self.buttonArray) {
                [button removeFromSuperview];
            }
            [self.buttonArray removeAllObjects];
            self.buttonArray = newButtonArray;
            self.statusLabel.text = text;
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
    [self.activityIndicator stopAnimating];
    
    self.iconView.image = image;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.iconView.alpha = 1.0f;
    } completion:nil];
}

- (void)setStatusIconWithActivityIndicator
{
    [self.activityIndicator startAnimating];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.iconView.alpha = 0.0f;
    } completion:nil];
}

- (void)makeStatusLabelDisappearWithSize:(CGSize)size
{
    self.statusLabel.frame = CGRectMake(CGRectGetMaxX(self.iconView.frame) + 12, 12, size.width, size.height);
    CATransform3D _3Dt = CATransform3DMakeRotation(-M_PI_2, 1.0, 0.0, 0.0);
    self.statusLabel.layer.shouldRasterize = TRUE;
    self.statusLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.statusLabel.layer.transform = _3Dt;
    
    for (UIButton *button in self.buttonArray) {
        button.alpha = 0.0f;
    }
}

- (void)prepareStatusLabelToAppearWithSize:(CGSize)size
{
    CATransform3D _3Dt = CATransform3DMakeRotation(-M_PI_2, 1.0, 0.0, 0.0);
    self.statusLabel.layer.shouldRasterize = TRUE;
    self.statusLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.statusLabel.layer.transform = _3Dt;
    [self.statusLabel sizeToFit];
    CGRect statusLabelTmpFrame = self.statusLabel.frame;
    statusLabelTmpFrame.origin.x = CGRectGetMaxX(self.iconView.frame) + 12;
    statusLabelTmpFrame.origin.y = 12;
    self.statusLabel.frame = statusLabelTmpFrame;
    //self.statusLabel.backgroundColor = [UIColor redColor];
    self.statusLabel.numberOfLines = 0;
    
    for (UIButton *button in self.buttonArray) {
        button.alpha = 0.0f;
        
        CGSize textSize = [[button titleForState:UIControlStateNormal] sizeWithFont:self.buttonFont constrainedToSize:self.maxSize lineBreakMode:UILineBreakModeTailTruncation];
        button.bounds = CGRectMake(0, 0, 12 + textSize.width + 12, 8 + textSize.height + 8);
        button.center = CGPointMake(self.bounds.size.width/2, 12 + size.height + 12 + button.bounds.size.height/2 + [self.buttonArray indexOfObject:button] * (button.bounds.size.height + 12));
        [self addSubview:button];
    }
}

- (void)makeStatusLabelAppearWithSize:(CGSize)size
{
    self.statusLabel.frame = CGRectMake(CGRectGetMaxX(self.iconView.frame) + 12, 12, size.width, size.height);
    CATransform3D _3Dt = CATransform3DMakeRotation(0, 1.0, 0.0, 0.0);
    self.statusLabel.layer.shouldRasterize = TRUE;
    self.statusLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.statusLabel.layer.transform = _3Dt;
    
    for (UIButton *button in self.buttonArray) {
        button.alpha = 1.0f;
    }
}

- (void)resizeStatusViewWithLabelSize:(CGSize)size andButtonCount:(NSInteger)buttonCount
{
    self.bounds = CGRectMake(0, 0, CGRectGetMaxX(self.iconView.frame) + 12 + size.width + 12, 12 + size.height + 0 + buttonCount * (44 + 12));
}

- (void)clickedButton:(id)sender
{
    NSLog(@"clickedButton with tag: %i", [(UIButton *)sender tag]);
    
    if ([self.delegate respondsToSelector:@selector(statusView:clickedButtonAtIndex:)]) {
        [self.delegate statusView:self clickedButtonAtIndex:[(UIButton *)sender tag]];
    }
}

- (void)dealloc
{
    [self.buttonArray removeAllObjects];
    [self.buttonArray release];
    
    [self.statusFont release];
    
    [self.statusLabel release];
    [self.iconView release];
    [self.activityIndicator release];
    [super dealloc];
}

@end

#import <objc/runtime.h>

@implementation UIView (FPStatusView)

static char UIViewStatusView;

@dynamic statusView;

- (void)showFPStatusViewAtCenterWithText:(NSString *)text andStatusIcon:(FPStatusIcon)icon
{
    if (self.statusView.alpha == 0) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
            self.statusView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
    [self addSubview:self.statusView];
    
    self.statusView.center = self.center;
    [self.statusView setStatusWithText:text andStatusIcon:icon];
}

- (void)showFPStatusViewFromBottomWithText:(NSString *)text andStatusIcon:(FPStatusIcon)icon
{
    NSLog(@"TODOOOOOOOOO");
}

- (void)dismissFPStatusView
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.statusView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.statusView removeFromSuperview];
    }];
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
        statusView.alpha = 0.0;
        self.statusView = statusView;
    }
    return statusView;
}

@end
