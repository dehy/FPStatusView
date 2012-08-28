//
//  ViewController.m
//  FPStatusViewDemo
//
//  Created by Arnaud de Mouhy on 23/07/12.
//  Copyright (c) 2012 Flying Pingu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)showStatusOne:(id)sender
{
    [_statusView setStatusWithText:@"Status One" andStatusIcon:FPStatusWarning];
}

- (IBAction)showStatusTwo:(id)sender
{
    [_statusView setStatusWithText:@"Status Two :" andStatusIcon:FPStatusError andButtonTitles:@"Button 1", @"Button 2", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _statusView = [[FPStatusView alloc] initWithFrame:CGRectZero];
    _statusView.center = self.view.center;
    
    [self.view addSubview:_statusView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
