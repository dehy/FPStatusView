//
//  FPStatusView.h
//  FPStatusViewDemo
//
//  Created by Arnaud de Mouhy on 28/08/12.
//  Copyright (c) 2012 Flying Pingu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef enum {
    FPStatusLoading,
    FPStatusWarning,
    FPStatusError,
    FPStatusHungUp,
    FPStatusRinging,
    FPStatusCalling
} FPStatusIcon;

@class FPStatusView;

@protocol FPStatusViewDelegate <NSObject>

- (void)statusView:(FPStatusView *)statusView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface FPStatusView : UIView

@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UILabel *statusLabel;

@property (nonatomic, assign) CGSize maxSize;
@property (nonatomic, retain) UIFont *statusFont;

@property (nonatomic, retain) UIFont *buttonFont;

@property (nonatomic, retain) NSMutableArray *buttonArray;

@property (nonatomic, assign) id delegate;

- (id)initWithFrame:(CGRect)frame;

- (void)setStatusWithText:(NSString *)text andStatusIcon:(FPStatusIcon)icon;
- (void)setStatusWithText:(NSString *)text andStatusIcon:(FPStatusIcon)icon andButtonTitles:(NSString *)buttonTitle, ... NS_REQUIRES_NIL_TERMINATION;
- (void)setStatusIconWithImage:(UIImage *)image;
- (void)setStatusIconWithActivityIndicator;

- (void)makeStatusLabelDisappearWithSize:(CGSize)size;
- (void)prepareStatusLabelToAppearWithSize:(CGSize)size;
- (void)makeStatusLabelAppearWithSize:(CGSize)size;
- (void)resizeStatusViewWithLabelSize:(CGSize)size andButtonCount:(NSInteger)buttonCount;

- (void)clickedButton:(id)sender;

@end

@interface UIView (FPStatusView)

@property (nonatomic, retain) FPStatusView *statusView;

- (void)showFPStatusViewAtCenterWithText:(NSString *)text andStatusIcon:(FPStatusIcon)icon;
- (void)showFPStatusViewFromBottomWithText:(NSString *)text andStatusIcon:(FPStatusIcon)icon;
- (void)dismissFPStatusView;

@end