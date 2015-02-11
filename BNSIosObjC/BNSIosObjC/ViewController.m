//
//  ViewController.m
//  TestObjCPebbleConnectivity
//
//  Created by Kristina Gancheva on 11/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "PebbleDelegate.h"
#import "UIColorExtension.h"

@interface ViewController ()
@end

@implementation ViewController {
    __weak IBOutlet UITextView *commTracker;
    __weak IBOutlet UIButton *notifyButton;
}

- (void)viewDidLoad {
    commTracker.layer.borderColor = [[UIColor colorFromHex: @"#33b5e5"] CGColor];
    commTracker.layer.borderWidth = 3.0f;
    commTracker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    notifyButton.backgroundColor = [UIColor colorFromHex:@"#99cc00"];
    [notifyButton drawRect: CGRectMake(0, 0, 200, 80)];
    notifyButton.layer.cornerRadius = 10.0;
    [notifyButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [notifyButton setTitle:@"Notify Watch" forState:UIControlStateNormal];
    
    [[PebbleDelegate sharedInstance] addObserver:self forKeyPath:@"notification" options: NSKeyValueObservingOptionNew context:nil];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"notification"]) {
        [self updatePhone:[PebbleDelegate sharedInstance].notification];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction)updateWatch:(id)sender {
    [[PebbleDelegate sharedInstance] updateWatch];
}

- (void)updatePhone:(NSString *)update {
    //Update commTracker
    commTracker.text = [commTracker.text stringByAppendingString:update];
    commTracker.text = [commTracker.text stringByAppendingString:@"\n"];
}

- (void)clearCommTracker {
    commTracker.text = @"";
}

@end
