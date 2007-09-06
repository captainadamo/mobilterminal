// ShellKeyboard.h
#import <UIKit/UIKeyboardInputProtocol.h>
#import <UIKit/UIKeyboard.h>
#import "ShellView.h"

@interface ShellKeyboard : UIKeyboard
{
  bool _hidden;
}

// TODO: Init code that sets default values for _hidden

// TODO: Only show and toggle are called -- remove more dead code here
- (void)show:(ShellView*)shellView;
- (void)hide:(ShellView*)shellView;
- (void)toggle:(ShellView*)shellView;

@end
