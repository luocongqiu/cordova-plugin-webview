//
// Created by luocongqiu on 16/9/13.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@class CDVWebViewController;

@interface CDVWebView : CDVPlugin <UIWebViewDelegate> {
    BOOL _isShown;
    int _framesOpened;  // number of frames opened since the last time browser exited
    NSURL *initUrl;  // initial URL ThemeableBrowser opened with
    NSURL *originalUrl;
}

@property(nonatomic, retain) CDVWebViewController *webViewController;
@property(nonatomic, copy) NSString *callbackId;
@property(nonatomic, copy) NSRegularExpression *callbackIdPattern;

- (void)open:(CDVInvokedUrlCommand *)command;

- (void)close:(CDVInvokedUrlCommand *)command;

- (void)show:(CDVInvokedUrlCommand *)command;

- (void)show:(CDVInvokedUrlCommand *)command withAnimation:(BOOL)animated;

- (void)browserExit;

- (void)reload:(CDVInvokedUrlCommand *)command;
@end