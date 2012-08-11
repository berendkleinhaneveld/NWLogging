//
//  NWLIntroViewController.m
//  NWLogging
//
//  Created by leonard on 4/25/12.
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWLIntroViewController.h"


static UITextView *NWLLoggingDemoLogView = nil;
static void NWLLoggingDemoPrinter(NWLContext context, CFStringRef message, void *info) {
    NSDate *date = NSDate.date;
    NSCalendar *calendar = NSCalendar.currentCalendar;
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    NSString *s = nil;
    if (context.tag && *context.tag) {
        s = [NSString stringWithFormat:@"[%02i:%02i:%02i] [%s] %@\n", hour, minute, second, context.tag, message];
    } else {
        s = [NSString stringWithFormat:@"[%02i:%02i:%02i] %@\n", hour, minute, second, message];
    }
    NWLLoggingDemoLogView.text = [NWLLoggingDemoLogView.text stringByAppendingString:s];
}


@implementation NWLIntroViewController {
    UITextView *logView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Introduction";
    
    UITextView *about = [[UITextView alloc] init];
    about.textAlignment = UITextAlignmentLeft;
    about.font = [UIFont systemFontOfSize:10];
    about.editable = NO;
    about.text = @"Welcome to the introduction to NWLogging. NWLogging is a basic logging framework with a focus on performance and ease of use. It consists of a core (mostly) written in C and a set of convenience classes written in Objective-C.\n \nThis demo showcases the core components of NWLogging: printers and filters. Filters control which log lines are in effect and what action should be performed. Printers output text to a certain medium. This demo is purely based on the core, as defined in NWLogging.h, which was designed to have minimal inpact at runtime. It therefore does not do any thread locking or memory allocation. During the demo, keep eye on this view, the console, and the source code.";
    CGFloat height = [about.text sizeWithFont:about.font constrainedToSize:CGSizeMake(self.view.bounds.size.width - 20, 1000) lineBreakMode:UILineBreakModeWordWrap].height + 10;
    about.frame = CGRectMake(10, 10, self.view.bounds.size.width - 20, height);
    [self.view addSubview:about];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(10, 20 + height, self.view.bounds.size.width - 20, 40);
    [button setTitle:@"Run" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(run) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    logView = [[UITextView alloc] init];
    logView.frame = CGRectMake(10, 70 + height, self.view.bounds.size.width - 20, self.view.bounds.size.height - 130 - height);
    logView.backgroundColor = UIColor.blackColor;
    logView.textColor = UIColor.whiteColor;
    logView.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:10]; // Courier-Bold or CourierNewPS-BoldMT
    logView.editable = NO;
    [self.view addSubview:logView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NWLLoggingDemoLogView = logView;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NWLLoggingDemoLogView = nil;
}

- (void)run
{
    NWLClearAll();
    NWLAddPrinter(NWLLoggingDemoPrinter, 0);
    
    NWLog(@"       A| Welcome to the logging overview demo.");
    NWLog(@"       B| Let's log some text and see what happens where..");
    NWLog(@"       C| The NWLLog function prints even when no matching rules are active.");
    
    // printing on default tags info and warn
    NWLogInfo(@"-| This line should not be visible, because info is not yet on");
    NWLPrintInfoInLib(NWL_LIB_STR);
    
    NWLogInfo(@"D| The 'info' tag is activated, allowing the display of this line.");
    NWLog(@"       E| Now let's activate the 'warn' tag.");
    NWLogWarn(@"-| Obviously this line should not be visible, warn is not yet active");
    NWLPrintWarnInLib(NWL_LIB_STR);
    NWLogWarn(@"F| There we go, let this be a warning!");
    
    NWLClearInfo();
    NWLClearWarn();
    
    // custom tags
    NWLogTag(test, @"-| This is logged under tag 'test', which is not active");
    NWLPrintTag("tst1");
    NWLogTag(tst1, @"G| This is logged under tst1");
    NWLPrintTag("tst2");
    NWLogTag(tst2, @"H| This is logged under tst2");
    NWLPrintTag("tst3");
    NWLogTag(tst3, @"I| This is logged under tst3");
    NWLPrintTag("tst4");
    NWLogTag(tst4, @"J| This is logged under tst4");
    NWLog(@"       K| Let's take a look inside the logging facility to see:");
    NWLAbout();

    NWLClearTag("tst1");
    NWLClearTag("tst2");
    NWLClearTag("tst3");
    NWLClearTag("tst4");

    // logging in C function
    runC();
    
    NWLogWarn(@"-| And of course this should not print nor break.");
    NWLPrintInfoInLib(NWL_LIB_STR);
    NWLogInfo(@"O| As a final demonstration, let's try out 'break', in 5 seconds.");

    NWLClearInfo();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        NWLBreakWarnInLib(NWL_LIB_STR);
        NWLogWarn(@"P| Tada! Now continue the debugger..");
        NWLPrintWarnInLib(NWL_LIB_STR);
        NWLogWarn(@"Q| That's it for this demo, thanks for watching.");
        
        // restore printers
        NWLRemovePrinter(NWLLoggingDemoPrinter, 0);
    });
}

static void runC() {
    NWLog(@"       L| This line is printed from a C function.");
    NWLogInfo(@"-| This line should not be visible, because info is not yet on");
    NWLPrintInfoInLib(NWL_LIB_STR);
    NWLogInfo(@"M| We're still in C, logging on 'info'.");
    NWLPrintTagInLib(NWL_LIB_STR, "C");
    NWLogTag(C, @"   N| And on the 'C' tag.");

    NWLClearInfo();
    NWLClearTag("C");
}

@end