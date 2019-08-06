//
//  ViewController.m
//  SimulateTouch
//
//  Created by 翟泉 on 2019/8/6.
//  Copyright © 2019 cezres. All rights reserved.
//

#import "ViewController.h"
#import "SimulateTouch.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SimulateTouch simulateTouchWithTarget:CGPointMake(100, 100) forWindow:self.view.window];
    });
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [event.allTouches.anyObject locationInView:self.view];
    NSLog(@"\n%s\n%@\n%@", __FUNCTION__, event, @(point));
}

@end
