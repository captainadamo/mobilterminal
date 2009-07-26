// MobileTerminalViewController.m
// MobileTerminal

#import "MobileTerminalViewController.h"

#import "VT100/ColorMap.h"
#import "Terminal/TerminalKeyboard.h"
#import "Terminal/TerminalGroupView.h"
#import "Terminal/TerminalView.h"
#import "MenuView.h"

@implementation MobileTerminalViewController

@synthesize contentView;
@synthesize terminalGroupView;
@synthesize terminalSelector;
@synthesize preferencesButton;
@synthesize menuButton;
@synthesize interfaceDelegate;
@synthesize menuView;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithCoder:(NSCoder *)decoder
{
  self = [super initWithCoder:decoder];
  if (self != nil) {
    terminalKeyboard = [[TerminalKeyboard alloc] init];
    keyboardShown = NO;    
  }
  return self;
}

- (void)registerForKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWasShown:)
                                               name:UIKeyboardDidShowNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWasHidden:)
                                               name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
  if (keyboardShown)
    return;
  keyboardShown = YES;

  NSDictionary* info = [aNotification userInfo];
  
  // Get the size of the keyboard.
  NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
  CGSize keyboardSize = [aValue CGRectValue].size;
  
  // Reset the height of the terminal to full screen not shown by the keyboard
  CGRect viewFrame = [contentView frame];
  viewFrame.size.height -= keyboardSize.height;
  contentView.frame = viewFrame;
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
  if (!keyboardShown)
    return;
  keyboardShown = NO;
  
  NSDictionary* info = [aNotification userInfo];
  
  // Get the size of the keyboard.
  NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
  CGSize keyboardSize = [aValue CGRectValue].size;  
  
  // Resize to the original height of the screen without the keyboard
  CGRect viewFrame = [contentView frame];
  viewFrame.size.height += keyboardSize.height;
  contentView.frame = viewFrame;
}

- (void)setShowKeyboard:(BOOL)showKeyboard
{
  if (showKeyboard) {
    [terminalKeyboard becomeFirstResponder];
  } else {
    [terminalKeyboard resignFirstResponder];
  }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch* touch = [touches anyObject];
  NSUInteger numTaps = [touch tapCount];
  if (numTaps < 2) {
    [self.nextResponder touchesBegan:touches withEvent:event];
  } else {
    // Double-tap: Toggle the keyboard
    shouldShowKeyboard = !shouldShowKeyboard;
    [self setShowKeyboard:shouldShowKeyboard];
  }
}

// Invoked when the page control is clicked to make a new terminal active.  The
// keyboard events are forwarded to the new active terminal and it is made the
// front-most terminal view.
- (void)terminalSelectionDidChange:(id)sender 
{
  TerminalView* terminalView =
      [terminalGroupView terminalAtIndex:[terminalSelector currentPage]];
  terminalKeyboard.inputDelegate = terminalView;
  [terminalGroupView bringTerminalToFront:terminalView];
}

// Invoked when the preferences button is pressed
- (void)preferencesButtonPressed:(id)sender 
{
  [interfaceDelegate preferencesButtonPressed];
}

// Invoked when the preferences button is pressed
- (void)menuButtonPressed:(id)sender 
{
  [menuView setHidden:![menuView isHidden]];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // TODO(allen):  This should be configurable
  shouldShowKeyboard = YES;

  // Adding the keyboard to the view has no effect, except that it is will
  // later allow us to make it the first responder so we can show the keyboard
  // on the screen.
  [[self view] addSubview:terminalKeyboard];
  [self registerForKeyboardNotifications];

  // The menu button points to the right, but for this context it should point
  // up, since the menu moves that way.
  menuButton.transform = CGAffineTransformMakeRotation(-90.0f * M_PI / 180.0f);
  [menuButton setNeedsLayout];  
  
  // Setup the page control that selects the active terminal
  [terminalSelector setNumberOfPages:[terminalGroupView terminalCount]];
  [terminalSelector setCurrentPage:0];
  // Make the first terminal active
  [self terminalSelectionDidChange:self];
}

- (void)viewDidAppear:(BOOL)animated
{
  [self setShowKeyboard:shouldShowKeyboard];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // This supports everything except for upside down, since upside down is most
  // likely accidental.
  switch (interfaceOrientation) {
    case UIInterfaceOrientationPortrait:
    case UIInterfaceOrientationLandscapeLeft:
    case UIInterfaceOrientationLandscapeRight:
      return YES;
    default:
      return NO;
  }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{  
  // We rotated, and almost certainly changed the frame size of the text view.
  [[self view] layoutSubviews];
}

- (void)didReceiveMemoryWarning {
	// TODO(allen): Should clear scrollback buffers to save memory? 
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  [terminalKeyboard release];
  [super dealloc];
}


@end