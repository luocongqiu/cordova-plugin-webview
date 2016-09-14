//
// Created by luocongqiu on 16/9/13.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVScreenOrientationDelegate.h>

@class CDVUIWebViewDelegate;
@class CDVWebView;
@class CDVWebViewOptions;

@interface CDVWebViewController : UIViewController <UIWebViewDelegate, CDVScreenOrientationDelegate, UIActionSheetDelegate> {
    NSString *_userAgent;
    NSString *_prevUserAgent;
    NSInteger _userAgentLockToken;
    UIStatusBarStyle _statusBarStyle;
    CDVWebViewOptions *_options;
    CDVUIWebViewDelegate *_webViewDelegate;
}

@property(nonatomic, strong) IBOutlet UIWebView *webView;
@property(nonatomic, strong) IBOutlet UILabel *titleLabel;
@property(nonatomic, strong) IBOutlet UIButton *backButton;
@property(nonatomic, strong) IBOutlet UIView *toolbar;

@property(nonatomic, weak) id <CDVScreenOrientationDelegate> orientationDelegate;
@property(nonatomic, weak) CDVWebView *navigationDelegate;
@property(nonatomic) NSURL *currentURL;

- (void)close;

- (void)reload;

- (void)navigateTo:(NSURL *)url;

- (void)showLocationBar;

- (void)showToolBar;

- (id)initWithUserAgent:(NSString *)userAgent prevUserAgent:(NSString *)prevUserAgent browserOptions:(CDVWebViewOptions *)browserOptions navigationDelete:(CDVWebView *)navigationDelegate statusBarStyle:(UIStatusBarStyle)statusBarStyle;

+ (UIColor *)colorFromRGBA:(NSString *)rgba;

@end