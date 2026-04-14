#import "AppDelegate.h"
#import "CanvasView.h"

@implementation AppDelegate {
    NSMutableArray<NSWindow *> *_managedWindows;
    NSInteger _windowCounter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _managedWindows = [NSMutableArray array];
        _windowCounter = 0;
    }
    return self;
}

// MARK: - Lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self buildMenuBar];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

// MARK: - Menu Construction

- (void)buildMenuBar {
    NSMenu *mainMenu = [[NSMenu alloc] init];

    // App menu (required for Quit, Hide, etc.)
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    NSMenu *appMenu = [[NSMenu alloc] init];
    [appMenu addItemWithTitle:@"About Windows"
                       action:@selector(orderFrontStandardAboutPanel:)
                keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Quit Windows"
                       action:@selector(terminate:)
                keyEquivalent:@"q"];
    appMenuItem.submenu = appMenu;
    [mainMenu addItem:appMenuItem];

    // "Windows" menu
    NSMenuItem *windowsMenuItem = [[NSMenuItem alloc] init];
    NSMenu *windowsMenu = [[NSMenu alloc] initWithTitle:@"Windows"];
    [windowsMenu addItemWithTitle:@"Create New Window"
                           action:@selector(createNewWindow)
                    keyEquivalent:@"n"];
    [windowsMenu addItemWithTitle:@"Delete Window"
                           action:@selector(deleteWindow)
                    keyEquivalent:@"w"];
    windowsMenuItem.submenu = windowsMenu;
    [mainMenu addItem:windowsMenuItem];

    // "Lines" menu
    NSMenuItem *linesMenuItem = [[NSMenuItem alloc] init];
    NSMenu *linesMenu = [[NSMenu alloc] initWithTitle:@"Lines"];
    [linesMenu addItemWithTitle:@"2 pt Line"
                         action:@selector(addLine)
                  keyEquivalent:@"1"];
    [linesMenu addItemWithTitle:@"Circle"
                         action:@selector(addCircle)
                  keyEquivalent:@"2"];
    [linesMenu addItemWithTitle:@"Rectangle"
                         action:@selector(addRectangle)
                  keyEquivalent:@"3"];
    linesMenuItem.submenu = linesMenu;
    [mainMenu addItem:linesMenuItem];

    [NSApplication sharedApplication].mainMenu = mainMenu;
}

// MARK: - Window Actions

- (void)createNewWindow {
    _windowCounter++;
    NSRect frame = [self cascadedFrameForIndex:_windowCounter];
    NSWindow *window = [[NSWindow alloc]
        initWithContentRect:frame
                  styleMask:(NSWindowStyleMaskTitled |
                             NSWindowStyleMaskClosable |
                             NSWindowStyleMaskResizable |
                             NSWindowStyleMaskMiniaturizable)
                    backing:NSBackingStoreBuffered
                      defer:NO];
    window.title = [NSString stringWithFormat:@"Window %ld", (long)_windowCounter];
    window.contentView = [[CanvasView alloc] initWithFrame:frame];
    window.releasedWhenClosed = NO;
    [window makeKeyAndOrderFront:nil];

    [_managedWindows addObject:window];
}

- (void)deleteWindow {
    if (_managedWindows.count == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"No Windows";
        alert.informativeText = @"There are no open windows to delete.";
        alert.alertStyle = NSAlertStyleInformational;
        [alert runModal];
        return;
    }
    NSWindow *window = _managedWindows.lastObject;
    [_managedWindows removeLastObject];
    [window close];
}

// MARK: - Drawing Actions

- (void)addLine      { [self addShapeToFrontWindow:CanvasShapeLine]; }
- (void)addCircle    { [self addShapeToFrontWindow:CanvasShapeCircle]; }
- (void)addRectangle { [self addShapeToFrontWindow:CanvasShapeRectangle]; }

- (void)addShapeToFrontWindow:(CanvasShape)shape {
    // Prefer the key (frontmost) managed window
    NSWindow *target = nil;
    for (NSWindow *w in _managedWindows) {
        if (w.isKeyWindow) {
            target = w;
            break;
        }
    }
    if (!target) {
        target = _managedWindows.lastObject;
    }

    if (![target.contentView isKindOfClass:[CanvasView class]]) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"No Window Available";
        alert.informativeText = @"Please create a window first (Windows \u2192 Create New Window).";
        alert.alertStyle = NSAlertStyleInformational;
        [alert runModal];
        return;
    }
    [(CanvasView *)target.contentView addShape:shape];
}

// MARK: - Helpers

- (NSRect)cascadedFrameForIndex:(NSInteger)index {
    CGFloat baseX  = 200.0;
    CGFloat baseY  = 200.0;
    CGFloat offset = 30.0 * (CGFloat)((index - 1) % 10);
    return NSMakeRect(baseX + offset, baseY - offset, 520.0, 400.0);
}

@end
