#import "GestureView.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Rendering.h>
#import <UIKit/CDStructures.h>

struct CGRect GSEventGetLocationInWindow(struct __GSEvent *ev);

@implementation GestureView
-initWithProcess:(SubProcess *)aProcess Frame:(struct CGRect)rect Pie:(PieView *)pie {
    if ((self = [super initWithFrame: rect])) {
        _shellProcess = aProcess;
        _pie = pie;
    }
    return self;
}

#define ARROW_KEY_SLOP 75.0

BOOL isGesture;
CGPoint start;

- (BOOL)ignoresMouseEvents { return NO; }
- (int)canHandleGestures { return YES; }
- (void)gestureEnded:(struct __GSEvent *)event { isGesture = NO; }
- (void)gestureStarted:(struct __GSEvent *)event { isGesture = YES;  }

- (void)mouseDown:(struct __GSEvent *)event {
    CGRect rect = GSEventGetLocationInWindow(event);
    start = rect.origin;
    [_pie show];
}

- (void)mouseDragged:(struct __GSEvent*)event {

}

- (void)mouseUp:(struct __GSEvent*)event {
    CGRect rect = GSEventGetLocationInWindow(event);
    CGPoint vector;
    vector.x = rect.origin.x - start.x;
    vector.y = rect.origin.y - start.y;

    float theta, r, absx, absy;
    absx = (vector.x>0)?vector.x:-vector.x;
    absy = (vector.y>0)?vector.y:-vector.y;
    r = (absx>absy)?absx:absy;//sqrt(vector.y*vector.y+vector.x+vector.x);
        theta = atan2(-vector.y, vector.x);
        NSLog(@"%f,%f: %f,%f\n", vector.y, -vector.x, r, theta);
        int zone = (int)((theta / (2 * 3.1415f * 0.125f)) + 0.5f + 4.0f);
        NSLog(@"%d\n", zone);
    if (r > 30.0f) {
        //unichar characters[] = {0x1B, '[', 0}, charCount = 3;
        NSString *characters = nil;
        switch (zone) {
            case 0:
            case 8:
                characters = @"\x1B[D";
                break;
            case 2:
                characters = @"\x1B[B";
                break;
            case 4:
                characters = @"\x1B[C";
                break;
            case 6:
                characters = @"\x1B[A";
                break;
            case 5:
                characters = @"\x03";
                break;
            case 7:
                characters = @"\x1B";
                break;
            case 1:
                characters = @"\x09";
                break;
            case 3:
                characters = @"\x04";
                break;
        }
        if (characters) [_shellProcess writeData: [characters dataUsingEncoding: NSASCIIStringEncoding]];
    }
/*
    int abs_x = abs((int)vector.x);
    int abs_y = abs((int)vector.y);
    if (abs_x > abs_y) {
        if (vector.x > ARROW_KEY_SLOP) {
            characters[2] = 'C';
        } else if (vector.x < -ARROW_KEY_SLOP) {
            characters[2] = 'D';
        }
    } else {
        if (vector.y > ARROW_KEY_SLOP) {
            characters[2] = 'B';
        } else if (vector.y < -ARROW_KEY_SLOP) {
            characters[2] = 'A';
        }
    }
    if (characters[2] == 0) {
        characters[0] = 0x09;
        charCount = 1;
    }
*/
    [_pie hide];
}

-(BOOL)canBecomeFirstResponder { return NO; }
-(BOOL)isOpaque { return NO; }
-(void)drawRect: (CGRect *)rect { }
@end
