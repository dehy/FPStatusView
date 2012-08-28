//
//  ViewController.h
//  FPStatusViewDemo
//
//  Created by Arnaud de Mouhy on 23/07/12.
//  Copyright (c) 2012 Flying Pingu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPStatusView.h"

@interface ViewController : UIViewController

- (IBAction)showStatusOne:(id)sender;
- (IBAction)showStatusTwo:(id)sender;

@property (nonatomic, retain) FPStatusView *statusView;

@end
