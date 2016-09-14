
#import <Cordova/CDVUserAgentUtil.h>
#import "CDVWebView.h"
#import "CDVWebViewController.h"
#import "CDVWebViewOptions.h"
#import "CDVWebViewNavigationController.h"

typedef NSDictionary *dictionary;

@implementation CDVWebView

- (void)pluginInitialize {
    _isShown = NO;
    _framesOpened = 0;
    _callbackIdPattern = nil;
}

- (void)onReset {
    [self close:nil];
}

- (void)open:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;

    NSString *url = [command argumentAtIndex:0];
    NSString *target = [command argumentAtIndex:1 withDefault:@"_self"];
    NSDictionary *options = [command argumentAtIndex:2];

    self.callbackId = command.callbackId;

    if (url != nil) {
        NSURL *baseUrl = [self.webViewEngine URL];
        NSURL *absoluteUrl = [[NSURL URLWithString:url relativeToURL:baseUrl] absoluteURL];

        initUrl = absoluteUrl;

        if ([self isSystemUrl:absoluteUrl]) {
            target = @"_system";
        }

        if ([target isEqualToString:@"_self"]) {
            [self openInCordovaWebView:absoluteUrl];
        } else if ([target isEqualToString:@"_system"]) {
            [self openInSystem:absoluteUrl];
        } else {
            [self openInWebView:absoluteUrl withOptions:options];
        }

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"incorrect number of arguments"];
    }

    [pluginResult setKeepCallback:@YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (BOOL)isSystemUrl:(NSURL *)url {
    NSDictionary *systemUrls = @{
            @"itunes.apple.com": @YES,
            @"search.itunes.apple.com": @YES,
            @"appsto.re": @YES
    };
    return systemUrls[[url host]] != nil;
}

- (void)openInWebView:(NSURL *)url withOptions:(NSDictionary *)options {
    CDVWebViewOptions *browserOptions = [self parseOptions:options];

    if (self.webViewController == nil) {
        NSString *originalUA = [CDVUserAgentUtil originalUserAgent];
        self.webViewController = [[CDVWebViewController alloc]
                initWithUserAgent:originalUA prevUserAgent:[self.commandDelegate userAgent]
                   browserOptions:browserOptions
                 navigationDelete:self
                   statusBarStyle:[UIApplication sharedApplication].statusBarStyle];

        if ([self.viewController conformsToProtocol:@protocol(CDVScreenOrientationDelegate)]) {
            self.webViewController.orientationDelegate = (UIViewController <CDVScreenOrientationDelegate> *) self.viewController;
        }
    }

    [self.webViewController showLocationBar];
    [self.webViewController showToolBar];

    self.webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

    // UIWebView options
    self.webViewController.webView.scalesPageToFit = YES;
    self.webViewController.webView.mediaPlaybackRequiresUserAction = NO;
    self.webViewController.webView.allowsInlineMediaPlayback = NO;
    self.webViewController.webView.keyboardDisplayRequiresUserAction = YES;
    self.webViewController.webView.suppressesIncrementalRendering = NO;
    [self.webViewController navigateTo:url];
    [self show:nil withAnimation:YES];
}

- (CDVWebViewOptions *)parseOptions:(NSDictionary *)options {
    CDVWebViewOptions *obj = [[CDVWebViewOptions alloc] init];
    if (!options) {
        return obj;
    }

    NSString *headBarBg = [options valueForKey:@"headBarBg"];
    if (headBarBg) {
        obj.headBarBg = headBarBg;
    }

    NSString *titleColor = [options valueForKey:@"titleColor"];
    if (titleColor) {
        obj.titleColor = titleColor;
    }

    CGFloat headBarHeight = [[options valueForKey:@"headBarHeight"] floatValue];
    if (headBarHeight) {
        obj.headBarHeight = headBarHeight;
    }
    return obj;
}

- (void)openInCordovaWebView:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webViewEngine loadRequest:request];
}

- (void)openInSystem:(NSURL *)url {
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else { // handle any custom schemes to plugins
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    }
}

- (void)close:(CDVInvokedUrlCommand *)command {
    if (self.webViewController == nil) {
        [self emitEvent:@{
                @"type": @"warning",
                @"code": @"unexpected",
                @"message": @"Close called but already closed."
        }];
        return;
    }
    [self.webViewController close];
}

- (void)show:(CDVInvokedUrlCommand *)command {
    [self show:<#(CDVInvokedUrlCommand *)command#> withAnimation:YES];
}

- (void)show:(CDVInvokedUrlCommand *)command withAnimation:(BOOL)animated {
    if (self.viewController == nil) {
        [self emitEvent:@{
                @"code": @"warning",
                @"message": @"已经关闭"
        }];
        return;
    }
    if (_isShown) {
        [self emitEvent:@{
                @"code": @"warning",
                @"message": @"已经显示"
        }];
        return;
    }

    _isShown = YES;

    CDVWebViewNavigationController *nav = [[CDVWebViewNavigationController alloc] initWithRootViewController:self.webViewController];
    nav.orientationDelegate = self.webViewController;
    nav.navigationBarHidden = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.webViewController != nil) {
            [self.viewController presentViewController:nav animated:animated completion:nil];
        }
    });
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    BOOL isTopLevelNavigation = [request.URL isEqual:[request mainDocumentURL]];

    if ([self isSystemUrl:url]) {
        [[UIApplication sharedApplication] openURL:url];
        if (originalUrl != nil
                && [[originalUrl absoluteString] isEqualToString:[initUrl absoluteString]]
                && _framesOpened == 1) {

            [self emitEvent:@{
                    @"code": @"ThemeableBrowserRedirectExternalOnOpen",
                    @"message": @"ThemeableBrowser redirected to open an external app on fresh start"
            }];
        }
        return NO;
    } else if ((self.callbackId != nil) && isTopLevelNavigation) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"type": @"loadstart", @"url": [url absoluteString]}];
        [pluginResult setKeepCallback:@YES];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    }
    originalUrl = request.URL;

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    _framesOpened++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.callbackId != nil) {
        NSString *url = [self.webViewController.currentURL absoluteString];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"type": @"loadstop", @"url": url}];
        [pluginResult setKeepCallback:@YES];
        originalUrl = nil;
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.callbackId != nil) {
        NSString *url = [self.webViewController.currentURL absoluteString];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"type": @"loaderror", @"url": url, @"code": @(error.code), @"message": error.localizedDescription}];
        [pluginResult setKeepCallback:@YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    }
}

- (void)browserExit {
    if (self.callbackId != nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"type": @"exit"}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        self.callbackId = nil;
    }
    self.webViewController.navigationDelegate = nil;
    self.webViewController = nil;
    self.callbackId = nil;
    self.callbackIdPattern = nil;

    _framesOpened = 0;
    _isShown = NO;
}

- (void)reload:(CDVInvokedUrlCommand *)command {

}

- (void)emitEvent:(NSDictionary *)event {
    if (self.callbackId != nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:event];
        [pluginResult setKeepCallback:@YES];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    }
}

@end