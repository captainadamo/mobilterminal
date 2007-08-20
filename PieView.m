#import "PieView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIAnimator.h>
#import <UIKit/UITransformAnimation.h>
#import <UIKit/UIView-Rendering.h>

@implementation PieView
-(BOOL)ignoresMouseEvents { return YES; }

-initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        visibleFrame = frame;
        hiddenFrame = CGRectMake(frame.origin.x+(frame.size.width/2.0f), frame.origin.y+(frame.size.height/2.0f), 1.0f, 1.0f);
        _visible = YES;
    }
    return self;
}

-(void)show {
    if (!_visible) {
        _visible = YES;
        [self setTransform:CGAffineTransformMake(0.01f,0,0,0.01f,0,480)];
        //[self setFrame:hiddenFrame];
        UITransformAnimation *scaleAnim = [[UITransformAnimation alloc] initWithTarget: self];
        [scaleAnim setStartTransform: CGAffineTransformMake(0.01f,0,0,0.01f,0,0)];
        [scaleAnim setEndTransform: CGAffineTransformMake(1,0,0,1,0,0)];
        [[[UIAnimator alloc] init] addAnimation:scaleAnim withDuration:0.15f start:YES]; 
        //[self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
        //[self setFrame:visibleFrame];
    }
}

-(void)hide { [self hideSlow:NO]; }

-(void)hideSlow:(BOOL)slow {
    if (_visible) {
        [self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
        //[self setFrame:visibleFrame];
        UITransformAnimation *scaleAnim = [[UITransformAnimation alloc] initWithTarget: self];
        [scaleAnim setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
        [scaleAnim setEndTransform: CGAffineTransformMake(0.01f,0,0,0.01f,0,0)];
        [[[UIAnimator alloc] init] addAnimation:scaleAnim withDuration:(slow ? 1.0f : 0.25f) start:YES]; 
        _visible = NO;
    }
}
@end
