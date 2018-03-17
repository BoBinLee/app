#include "driver.h"
#include "file.h"
#include "json.h"
#include "menu.h"
#include "notification.h"
#include "sandbox.h"
#include "window.h"

@implementation Driver
+ (instancetype)current {
  static Driver *driver = nil;

  @synchronized(self) {
    if (driver == nil) {
      driver = [[Driver alloc] init];
      NSApplication *app = [NSApplication sharedApplication];
      app.delegate = driver;
    }
  }
  return driver;
}

- (instancetype)init {
  self = [super init];

  self.elements = [[NSMutableDictionary alloc] init];
  self.golang = [[GoBridge alloc] init];
  self.macRPC = [[MacRPC alloc] init];
  self.goRPC = [[GoRPC alloc] init];

  // Driver handlers.
  [self.macRPC handle:@"driver.Run"
          withHandler:^(id in, NSString *returnID) {
            return [self run:in return:returnID];
          }];
  [self.macRPC handle:@"driver.Bundle"
          withHandler:^(id in, NSString *returnID) {
            return [self bundle:in return:returnID];
          }];
  [self.macRPC handle:@"driver.SetContextMenu"
          withHandler:^(id in, NSString *returnID) {
            return [self setContextMenu:in return:returnID];
          }];
  [self.macRPC handle:@"driver.SetMenubar"
          withHandler:^(id in, NSString *returnID) {
            return [self setMenubar:in return:returnID];
          }];
  [self.macRPC handle:@"driver.SetDock"
          withHandler:^(id in, NSString *returnID) {
            return [self setDock:in return:returnID];
          }];
  [self.macRPC handle:@"driver.SetDockIcon"
          withHandler:^(id in, NSString *returnID) {
            return [self setDockIcon:in return:returnID];
          }];
  [self.macRPC handle:@"driver.SetDockBadge"
          withHandler:^(id in, NSString *returnID) {
            return [self setDockBadge:in return:returnID];
          }];
  [self.macRPC handle:@"driver.Share"
          withHandler:^(id in, NSString *returnID) {
            return [self share:in return:returnID];
          }];
  [self.macRPC handle:@"driver.Quit"
          withHandler:^(id in, NSString *returnID) {
            return [self quit:in return:returnID];
          }];

  // Window handlers.
  [self.macRPC handle:@"windows.New"
          withHandler:^(id in, NSString *returnID) {
            return [Window new:in return:returnID];
          }];
  [self.macRPC handle:@"windows.Load"
          withHandler:^(id in, NSString *returnID) {
            return [Window load:in return:returnID];
          }];
  [self.macRPC handle:@"windows.Render"
          withHandler:^(id in, NSString *returnID) {
            return [Window render:in return:returnID];
          }];
  [self.macRPC handle:@"windows.RenderAttributes"
          withHandler:^(id in, NSString *returnID) {
            return [Window renderAttributes:in return:returnID];
          }];
  [self.macRPC handle:@"windows.Position"
          withHandler:^(id in, NSString *returnID) {
            return [Window position:in return:returnID];
          }];
  [self.macRPC handle:@"windows.Move"
          withHandler:^(id in, NSString *returnID) {
            return [Window move:in return:returnID];
          }];
  [self.macRPC handle:@"windows.Center"
          withHandler:^(id in, NSString *returnID) {
            return [Window center:in return:returnID];
          }];
  [self.macRPC handle:@"windows.Size"
          withHandler:^(id in, NSString *returnID) {
            return [Window size:in return:returnID];
          }];
  [self.macRPC handle:@"windows.Resize"
          withHandler:^(id in, NSString *returnID) {
            return [Window resize:in return:returnID];
          }];
  [self.macRPC handle:@"windows.Focus"
          withHandler:^(id in, NSString *returnID) {
            return [Window focus:in return:returnID];
          }];
  [self.macRPC handle:@"windows.ToggleFullScreen"
          withHandler:^(id in, NSString *returnID) {
            return [Window toggleFullScreen:in return:returnID];
          }];
  [self.macRPC handle:@"windows.ToggleMinimize"
          withHandler:^(id in, NSString *returnID) {
            return [Window toggleMinimize:in return:returnID];
          }];
  [self.macRPC handle:@"windows.Close"
          withHandler:^(id in, NSString *returnID) {
            return [Window close:in return:returnID];
          }];

  // Menu handlers.
  [self.macRPC handle:@"menus.New"
          withHandler:^(id in, NSString *returnID) {
            return [Menu new:in return:returnID];
          }];
  [self.macRPC handle:@"menus.Load"
          withHandler:^(id in, NSString *returnID) {
            return [Menu load:in return:returnID];
          }];
  [self.macRPC handle:@"menus.Render"
          withHandler:^(id in, NSString *returnID) {
            return [Menu render:in return:returnID];
          }];
  [self.macRPC handle:@"menus.RenderAttributes"
          withHandler:^(id in, NSString *returnID) {
            return [Menu renderAttributes:in return:returnID];
          }];
  [self.macRPC handle:@"menus.Delete"
          withHandler:^(id in, NSString *returnID) {
            return [Menu delete:in return:returnID];
          }];

  // File panel handlers.
  [self.macRPC handle:@"files.NewPanel"
          withHandler:^(id in, NSString *returnID) {
            return [FilePanel newFilePanel:in return:returnID];
          }];
  [self.macRPC handle:@"files.NewSavePanel"
          withHandler:^(id in, NSString *returnID) {
            return [FilePanel newSaveFilePanel:in return:returnID];
          }];

  // Notification handlers.
  [self.macRPC handle:@"notifications.New"
          withHandler:^(id in, NSString *returnID) {
            return [Notification new:in return:returnID];
          }];

  // Notifications.
  NSUserNotificationCenter *userNotificationCenter =
      [NSUserNotificationCenter defaultUserNotificationCenter];
  userNotificationCenter.delegate = self;

  return self;
}

- (void)run:(NSDictionary *)in return:(NSString *)returnID {
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  [NSApp activateIgnoringOtherApps:YES];
  [NSApp run];

  [self.macRPC return:returnID withOutput:nil andError:nil];
}

- (void)bundle:(NSDictionary *)in return:(NSString *)returnID {
  NSBundle *mainBundle = [NSBundle mainBundle];

  NSMutableDictionary *out = [[NSMutableDictionary alloc] init];
  out[@"AppName"] = mainBundle.infoDictionary[@"CFBundleName"];
  out[@"Resources"] = mainBundle.resourcePath;
  out[@"Support"] = [self support];

  [self.macRPC return:returnID withOutput:out andError:nil];
}

- (NSString *)support {
  NSBundle *mainBundle = [NSBundle mainBundle];

  if ([mainBundle isSandboxed]) {
    return NSHomeDirectory();
  }

  NSArray *paths = NSSearchPathForDirectoriesInDomains(
      NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *applicationSupportDirectory = [paths firstObject];

  if (mainBundle.bundleIdentifier.length == 0) {
    return [NSString
        stringWithFormat:@"%@/goapp/{appname}", applicationSupportDirectory];
  }
  return [NSString stringWithFormat:@"%@/%@", applicationSupportDirectory,
                                    mainBundle.bundleIdentifier];
}

- (void)setContextMenu:(NSString *)menuID return:(NSString *)returnID {
  defer(returnID, ^{
    Menu *menu = self.elements[menuID];
    NSWindow *win = NSApp.keyWindow;

    if (win == nil) {
      [self.macRPC return:returnID withOutput:nil
          andError:@"no window to host the context menu"];
      return;
    }

    [menu.root popUpMenuPositioningItem:menu.root.itemArray[0]
                             atLocation:[win mouseLocationOutsideOfEventStream]
                                 inView:win.contentView];
    [self.macRPC return:returnID withOutput:nil andError:nil];
  });
}

- (void)setMenubar:(NSString *)menuID return:(NSString *)returnID {
  defer(returnID, ^{
    Menu *menu = self.elements[menuID];
    NSApp.mainMenu = menu.root;
    [self.macRPC return:returnID withOutput:nil andError:nil];
  });
}

- (void)setDock:(NSString *)menuID return:(NSString *)returnID {
  defer(returnID, ^{
    Menu *menu = self.elements[menuID];
    self.dock = menu.root;
    [self.macRPC return:returnID withOutput:nil andError:nil];
  });
}

- (void)setDockIcon:(NSString *)icon return:(NSString *)returnID {
  defer(returnID, ^{
    if (icon.length != 0) {
      NSApp.applicationIconImage = [[NSImage alloc] initByReferencingFile:icon];
    } else {
      NSApp.applicationIconImage = nil;
    }

    [self.macRPC return:returnID withOutput:nil andError:nil];
  });
}

- (void)setDockBadge:(NSString *)badge return:(NSString *)returnID {
  defer(returnID, ^{
    [NSApp.dockTile setBadgeLabel:badge];
    [self.macRPC return:returnID withOutput:nil andError:nil];
  });
}

- (void)share:(NSDictionary *)in return:(NSString *)returnID {
  defer(returnID, ^{
    NSWindow *rawWindow = NSApp.keyWindow;
    if (rawWindow == nil) {
      [NSException raise:@"NoKeyWindowExeption"
                  format:@"no window to host the share menu"];
    }
    Window *win = (Window *)rawWindow.windowController;

    id share = in[@"Share"];
    if ([in[@"Type"] isEqual:@"url"]) {
      [NSURL URLWithString:share];
    }

    NSPoint pos = [win.window mouseLocationOutsideOfEventStream];
    pos = [win.webview convertPoint:pos fromView:rawWindow.contentView];
    NSRect rect = NSMakeRect(pos.x, pos.y, 1, 1);

    NSSharingServicePicker *picker =
        [[NSSharingServicePicker alloc] initWithItems:@[ share ]];
    [picker showRelativeToRect:rect
                        ofView:win.webview
                 preferredEdge:NSMinYEdge];

    [self.macRPC return:returnID withOutput:nil andError:nil];
  });
}

- (void)quit:(id)in return:(NSString *)returnID {
  defer(returnID, ^{
    [NSApp terminate:self];
    [self.macRPC return:returnID withOutput:nil andError:nil];
  });
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [self.golang request:@"/driver/run" payload:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
  [self.golang request:@"/driver/focus" payload:nil];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
  [self.golang request:@"/driver/blur" payload:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender
                    hasVisibleWindows:(BOOL)flag {
  NSString *payload = flag ? @"true" : @"false";
  [self.golang request:@"/driver/reopen" payload:payload];
  return YES;
}

- (void)application:(NSApplication *)sender
          openFiles:(NSArray<NSString *> *)filenames {
  NSString *payload = [JSONEncoder encodeObject:filenames];
  [self.golang request:@"/driver/filesopen" payload:payload];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
  NSAppleEventManager *appleEventManager =
      [NSAppleEventManager sharedAppleEventManager];
  [appleEventManager
      setEventHandler:self
          andSelector:@selector(handleGetURLEvent:withReplyEvent:)
        forEventClass:kInternetEventClass
           andEventID:kAEGetURL];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event
           withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
  NSString *rawurl =
      [event paramDescriptorForKeyword:keyDirectObject].stringValue;
  NSString *payload = [JSONEncoder encodeString:rawurl];
  [self.golang request:@"/driver/urlopen" payload:payload];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:
    (NSApplication *)sender {
  NSString *res = [self.golang requestWithResult:@"/driver/quit" payload:nil];
  return [JSONDecoder decodeBool:res];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [self.golang requestWithResult:@"/driver/exit" payload:nil];
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
  return self.dock;
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification {
  return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification {
  [self.golang request:[NSString stringWithFormat:@"/notification/reply?id=%@",
                                                  notification.identifier]
               payload:[JSONEncoder encodeString:notification.response.string]];
}
@end