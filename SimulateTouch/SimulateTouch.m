//
//  SimulateTouch.m
//  SimulateTouch
//
//  Created by 翟泉 on 2019/8/6.
//  Copyright © 2019 cezres. All rights reserved.
//

#import "SimulateTouch.h"
#import <objc/runtime.h>

@interface UITouch (Synthesize)

- (id)initInView:(UIView *)view;
- (void)setPhase:(UITouchPhase)phase;
- (void)setLocationInWindow:(CGPoint)location;

@end

@interface UIEvent (Synthesize)

- (id)initWithTouch:(UITouch *)touch;

@end

@interface SimulateTargetView : UIView

@end

@implementation SimulateTouch

+ (void)simulateTouchWithTarget:(CGPoint)point forWindow:(UIWindow *)window {
    SimulateTargetView *targetView = [SimulateTargetView new];
    targetView.frame = CGRectMake(point.x - 1, point.y - 1, 2, 2);
    [window addSubview:targetView];

    UITouch *touch = [[UITouch alloc] initInView:targetView];
    UIEvent *eventDown = [[UIEvent alloc] initWithTouch:touch];

    [touch.view touchesBegan:[eventDown allTouches] withEvent:eventDown];

    [touch setPhase:UITouchPhaseEnded];
    UIEvent *eventUp = [[UIEvent alloc] initWithTouch:touch];

    [touch.view touchesEnded:[eventUp allTouches] withEvent:eventUp];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [targetView removeFromSuperview];
    });
}

@end

@implementation UITouch (Synthesize)

//
// initInView:phase:
//
// Creats a UITouch, centered on the specified view, in the view's window.
// Sets the phase as specified.
//
- (id)initInView:(UIView *)view {
    self = [super init];
    if (self != nil) {
        CGRect frameInWindow;
        if ([view isKindOfClass:[UIWindow class]]) {
            frameInWindow = view.frame;
        }
        else {
            frameInWindow =
            [view.window convertRect:view.frame fromView:view.superview];
        }

        NSInteger _tapCount = 1;
        CGPoint _locationInWindow = CGPointMake(frameInWindow.origin.x + 0.5 * frameInWindow.size.width, frameInWindow.origin.y + 0.5 * frameInWindow.size.height);
        CGPoint _previousLocationInWindow = _locationInWindow;

        UIView *target = [view.window hitTest:_locationInWindow withEvent:nil];

        UIWindow* _window = view.window;
        UIView* _view = target;
        UITouchPhase _phase = UITouchPhaseBegan;
//        _touchFlags._firstTouchForView = 1;
//        _touchFlags._isTap = 1;
        NSTimeInterval _timestamp = [NSDate timeIntervalSinceReferenceDate];


        [self setValue:@(_tapCount) forKey:@"_tapCount"];
        [self setValue:[NSValue valueWithCGPoint:_locationInWindow] forKey:@"_locationInWindow"];
        [self setValue:[NSValue valueWithCGPoint:_previousLocationInWindow] forKey:@"_previousLocationInWindow"];
        [self setValue:_window forKey:@"_window"];
        [self setValue:_view forKey:@"_view"];
        [self setValue:@(_phase) forKey:@"_phase"];
        [self setValue:[NSNumber numberWithDouble:_timestamp] forKey:@"_timestamp"];
    }
    return self;
}

//
// setPhase:
//
// Setter to allow access to the _phase member.
//
- (void)setPhase:(UITouchPhase)phase {
    UITouchPhase _phase = phase;
    NSTimeInterval _timestamp = [NSDate timeIntervalSinceReferenceDate];
    [self setValue:[NSNumber numberWithInteger:_phase] forKey:@"_phase"];
    [self setValue:[NSNumber numberWithDouble:_timestamp] forKey:@"_timestamp"];
}

//
// setPhase:
//
// Setter to allow access to the _locationInWindow member.
//
- (void)setLocationInWindow:(CGPoint)location {
    CGPoint _previousLocationInWindow = [[self valueForKey:@"_locationInWindow"] CGPointValue];;
    CGPoint _locationInWindow = location;
    NSTimeInterval _timestamp = [NSDate timeIntervalSinceReferenceDate];
    [self setValue:[NSValue valueWithCGPoint:_previousLocationInWindow] forKey:@"_previousLocationInWindow"];
    [self setValue:[NSValue valueWithCGPoint:_locationInWindow] forKey:@"_locationInWindow"];
    [self setValue:[NSNumber numberWithDouble:_timestamp] forKey:@"_timestamp"];
}

@end

//
// GSEvent is an undeclared object. We don't need to use it ourselves but some
// Apple APIs (UIScrollView in particular) require the x and y fields to be present.
//
@interface GSEventProxy : NSObject
{
@public
    unsigned int flags;
    unsigned int type;
    unsigned int ignored1;
    float x1;
    float y1;
    float x2;
    float y2;
    unsigned int ignored2[10];
    unsigned int ignored3[7];
    float sizeX;
    float sizeY;
    float x3;
    float y3;
    unsigned int ignored4[3];
}
@end
@implementation GSEventProxy
@end

//
// PublicEvent
//
// A dummy class used to gain access to UIEvent's private member variables.
// If UIEvent changes at all, this will break.
//
@interface PublicEvent : NSObject
{
@public
    GSEventProxy           *_event;
    NSTimeInterval          _timestamp;
    NSMutableSet           *_touches;
    CFMutableDictionaryRef  _keyedTouches;
}
@end

@implementation PublicEvent
@end

@interface UIEvent (Creation)

- (id)_initWithEvent:(GSEventProxy *)fp8 touches:(id)fp12;

@end

//
// UIEvent (Synthesize)
//
// A category to allow creation of a touch event.
//
@implementation UIEvent (Synthesize)

- (id)initWithTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:touch.window];
    GSEventProxy *gsEventProxy = [[GSEventProxy alloc] init];
    gsEventProxy->x1 = location.x;
    gsEventProxy->y1 = location.y;
    gsEventProxy->x2 = location.x;
    gsEventProxy->y2 = location.y;
    gsEventProxy->x3 = location.x;
    gsEventProxy->y3 = location.y;
    gsEventProxy->sizeX = 1.0;
    gsEventProxy->sizeY = 1.0;
    gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
    gsEventProxy->type = 3001;

    //
    // On SDK versions 3.0 and greater, we need to reallocate as a
    // UITouchesEvent.
    //
    Class touchesEventClass = objc_getClass("UITouchesEvent");
    if (touchesEventClass && ![[self class] isEqual:touchesEventClass]) {
        self = [touchesEventClass alloc];
    }

    return [self _initWithEvent:gsEventProxy touches:[NSSet setWithObject:touch]];
}

@end

@implementation SimulateTargetView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
}

@end
