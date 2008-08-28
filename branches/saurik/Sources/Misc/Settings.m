//
// Settings.m
// Terminal

#import "Settings.h"

#import <Foundation/NSUserDefaults.h>

#import "ColorMap.h"
#import "Constants.h"
#import "Menu.h"
#import "MobileTerminal.h"

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation TerminalConfig

@synthesize width;
@synthesize autosize;
@synthesize fontSize;
@synthesize fontWidth;
@dynamic font;
@dynamic args;
@dynamic colors;

- (id)init
{
    self = [super init];
    if (self) {
        autosize = YES;
        width = 45;
        fontSize = 12;
        fontWidth = 0.6f;
        font = @"CourierNewPS-BoldMT";
        args = @"";
    }
    return self;
}

- (void)dealloc
{
    for (int c = 0; c < NUM_TERMINAL_COLORS; ++c)
        [_colors[c] release];

    [super dealloc];
}

- (NSString *)fontDescription
{
    return [NSString stringWithFormat:@"%@ %d", font, fontSize];
}

- (NSString *)font
{
    return font;
}

- (void)setFont:(NSString *)str
{
    if (font != str) {
        [font release];
        font = [str copy];
    }
}

- (NSString *)args { return args; }
- (void)setArgs:(NSString *)str
{
    if (args != str) {
        [args release];
        args = [str copy];
    }
}

- (UIColor **)colors
{
    return _colors;
}

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation Settings

@synthesize gestureFrameColor;
@synthesize multipleTerminals;

+ (Settings *)sharedInstance
{
    static Settings *instance = nil;
    if (instance == nil) instance = [[Settings alloc] init];
    return instance;
}

- (id)init
{
    self = [super init];

    terminalConfigs = [[NSArray arrayWithObjects:
        [[TerminalConfig alloc] init],
        [[TerminalConfig alloc] init],
        [[TerminalConfig alloc] init],
        [[TerminalConfig alloc] init], nil] retain];

    self.gestureFrameColor = colorWithRGBA(1, 1, 1, 0.05f);
    multipleTerminals = NO;
    menu = nil;
    swipeGestures = nil;
    arguments = @"";

    return self;
}

- (void)dealloc
{
    [gestureFrameColor release];
    [terminalConfigs release];

    [super dealloc];
}

- (void)registerDefaults
{
    int i;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:2];
    [d setObject:[NSNumber numberWithBool:MULTIPLE_TERMINALS] forKey:@"multipleTerminals"];

    // menu buttons

    NSArray *menuArray = [NSArray arrayWithContentsOfFile:@"/Applications/Terminal.app/menu.plist"];
    if (menuArray == nil)
        menuArray = [[Menu menu] getArray];
    [d setObject:menuArray forKey:@"menu"];

    // swipe gestures

    NSMutableDictionary *gestures = [NSMutableDictionary dictionaryWithCapacity:16];

    i = 0;
    while (DEFAULT_SWIPE_GESTURES[i][0]) {
        [gestures setObject:DEFAULT_SWIPE_GESTURES[i][1] forKey:DEFAULT_SWIPE_GESTURES[i][0]];
        i++;
    }

    [d setObject:gestures forKey:@"swipeGestures"];

    // terminals

    NSMutableArray *tcs = [NSMutableArray arrayWithCapacity:MAXTERMINALS];
    for (i = 0; i < MAXTERMINALS; i++) {
        NSMutableDictionary *tc = [NSMutableDictionary dictionaryWithCapacity:10];
        [tc setObject:[NSNumber numberWithBool:YES] forKey:@"autosize"];
        [tc setObject:[NSNumber numberWithInt:45] forKey:@"width"];
        [tc setObject:[NSNumber numberWithInt:12] forKey:@"fontSize"];
        [tc setObject:[NSNumber numberWithFloat:0.6f] forKey:@"fontWidth"];
        [tc setObject:@"CourierNewPS-BoldMT" forKey:@"font"];
        [tc setObject:(i > 0 ? @"clear" : @"")forKey:@"args"];

        NSMutableArray *ca = [NSMutableArray arrayWithCapacity:NUM_TERMINAL_COLORS];
        NSArray *colorValues;

        switch (i) { // bg color
            default: colorValues = [NSArray arrayWithColor:[UIColor blackColor]]; break;
            case 1: colorValues = [NSArray arrayWithColor:colorWithRGBA(0, 0.05f, 0, 1)]; break;
            case 2: colorValues = [NSArray arrayWithColor:colorWithRGBA(0, 0, 0.1f, 1)]; break;
            case 3: colorValues = [NSArray arrayWithColor:colorWithRGBA(0.1f, 0, 0, 1)]; break;
        };
        [ca addObject:colorValues];

        [ca addObject:[NSArray arrayWithColor:[UIColor whiteColor]]]; // fg color
        [ca addObject:[NSArray arrayWithColor:[UIColor yellowColor]]]; // bold color
        [ca addObject:[NSArray arrayWithColor:[UIColor redColor]]]; // cursor text
        [ca addObject:[NSArray arrayWithColor:[UIColor yellowColor]]]; // cursor color

        [tc setObject:ca forKey:@"colors"];
        [tcs addObject:tc];
    }
    [d setObject:tcs forKey:@"terminals"];

    NSArray *colorValues = [NSArray arrayWithColor:colorWithRGBA(1, 1, 1, 0.05f)];
    [d setObject:colorValues forKey:@"gestureFrameColor"];

    [defaults registerDefaults:d];
}

- (void)readUserDefaults
{
    int i, c;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *tcs = [defaults arrayForKey:@"terminals"];

    for (i = 0; i < MAXTERMINALS; i++) {
        TerminalConfig *config = [terminalConfigs objectAtIndex:i];
        NSDictionary *tc = [tcs objectAtIndex:i];
        config.autosize =   [[tc objectForKey:@"autosize"] boolValue];
        config.width =      [[tc objectForKey:@"width"] intValue];
        config.fontSize =   [[tc objectForKey:@"fontSize"] intValue];
        config.fontWidth =  [[tc objectForKey:@"fontWidth"] floatValue];
        config.font =        [tc objectForKey:@"font"];
        config.args =        [tc objectForKey:@"args"];
        for (c = 0; c < NUM_TERMINAL_COLORS; c++) {
            config.colors[c] = [[UIColor colorWithArray:[[tc objectForKey:@"colors"] objectAtIndex:c]] retain];
            [[ColorMap sharedInstance] setTerminalColor:config.colors[c] atIndex:c termid:i];
        }
    }

    multipleTerminals = MULTIPLE_TERMINALS && [defaults boolForKey:@"multipleTerminals"];
    menu = [[defaults arrayForKey:@"menu"] retain];
    swipeGestures = [[NSMutableDictionary dictionaryWithCapacity:24] retain];
    [swipeGestures setDictionary:[defaults objectForKey:@"swipeGestures"]];
    self.gestureFrameColor = [UIColor colorWithArray:[defaults arrayForKey:@"gestureFrameColor"]];
}

- (void)writeUserDefaults
{
    int i, c;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tcs = [NSMutableArray arrayWithCapacity:MAXTERMINALS];

    for (i = 0; i < MAXTERMINALS; i++) {
        TerminalConfig *config = [terminalConfigs objectAtIndex:i];
        NSMutableDictionary *tc = [NSMutableDictionary dictionaryWithCapacity:10];
        [tc setObject:[NSNumber numberWithBool:config.autosize] forKey:@"autosize"];
        [tc setObject:[NSNumber numberWithInt:config.width] forKey:@"width"];
        [tc setObject:[NSNumber numberWithInt:config.fontSize] forKey:@"fontSize"];
        [tc setObject:[NSNumber numberWithFloat:config.fontWidth] forKey:@"fontWidth"];
        [tc setObject:config.font forKey:@"font"];
        [tc setObject:config.args ? config.args : @"" forKey:@"args"];

        NSMutableArray *ca = [NSMutableArray arrayWithCapacity:NUM_TERMINAL_COLORS];
        NSArray *colorValues;

        for (c = 0; c < NUM_TERMINAL_COLORS; c++) {
            colorValues = [NSArray arrayWithColor:config.colors[c]];
            [ca addObject:colorValues];
        }

        [tc setObject:ca forKey:@"colors"];
        [tcs addObject:tc];
    }
    [defaults setObject:tcs forKey:@"terminals"];
    [defaults setBool:multipleTerminals forKey:@"multipleTerminals"];
    [defaults setObject:[[MobileTerminal menu] getArray] forKey:@"menu"];
    [defaults setObject:swipeGestures forKey:@"swipeGestures"];
    [defaults setObject:[NSArray arrayWithColor:gestureFrameColor] forKey:@"gestureFrameColor"];
    [defaults synchronize];
    [[[MobileTerminal menu] getArray] writeToFile:[NSHomeDirectory() stringByAppendingString:@"/Library/Preferences/com.googlecode.mobileterminal.menu.plist"] atomically:YES];
}

- (void)setCommand:(NSString *)command forGesture:(NSString *)zone
{
    [swipeGestures setObject:command forKey:zone];
}

- (NSArray *)terminalConfigs { return terminalConfigs; }
- (NSArray *)menu { return menu; }
- (NSDictionary *)swipeGestures { return swipeGestures; }
- (UIColor **)gestureFrameColorRef { return &gestureFrameColor; }
- (NSString *)arguments { return arguments; }

- (void)setArguments:(NSString *)str
{
    if (arguments != str) {
        [arguments release];
        arguments = [str copy];
    }
}

@end

/* vim: set syntax=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */