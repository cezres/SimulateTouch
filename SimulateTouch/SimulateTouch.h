//
//  SimulateTouch.h
//  SimulateTouch
//
//  Created by 翟泉 on 2019/8/6.
//  Copyright © 2019 cezres. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimulateTouch : NSObject

+ (void)simulateTouchWithTarget:(CGPoint)point forWindow:(UIWindow *)window;

@end
