//
// Created by luocongqiu on 16/9/13.
//
#import <Cordova/CDVUIWebViewDelegate.h>
#import <Cordova/CDVUserAgentUtil.h>
#import "CDVWebViewController.h"
#import "CDVWebViewOptions.h"
#import "CDVWebView.h"


@implementation CDVWebViewController

- (id)initWithUserAgent:(NSString *)userAgent prevUserAgent:(NSString *)prevUserAgent browserOptions:(CDVWebViewOptions *)options navigationDelete:(CDVWebView *)navigationDelegate statusBarStyle:(UIStatusBarStyle)statusBarStyle {
    self = [super init];
    if (self != nil) {
        _userAgent = userAgent;
        _prevUserAgent = prevUserAgent;
        _options = options;
        _webViewDelegate = [[CDVUIWebViewDelegate alloc] initWithDelegate:self];
        _navigationDelegate = navigationDelegate;
        _statusBarStyle = statusBarStyle;
        [self createViews];
    }
    return self;
}

- (void)createViews {
    // We create the views in code for primarily for ease of upgrades and not requiring an external .xib to be included

    CGRect webViewBounds = self.view.bounds;
    CGFloat toolbarHeight = _options.headBarHeight;
    webViewBounds.size.height -= toolbarHeight;
    self.webView = [[UIWebView alloc] initWithFrame:webViewBounds];

    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    [self.view addSubview:self.webView];
    [self.view sendSubviewToBack:self.webView];

    self.webView.delegate = _webViewDelegate;
    self.webView.backgroundColor = [UIColor whiteColor];

    self.webView.clearsContextBeforeDrawing = YES;
    self.webView.clipsToBounds = YES;
    self.webView.contentMode = UIViewContentModeScaleToFill;
    self.webView.multipleTouchEnabled = YES;
    self.webView.opaque = YES;
    self.webView.scalesPageToFit = NO;
    self.webView.userInteractionEnabled = YES;

    CGRect toolbarFrame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, toolbarHeight);

    self.toolbar = [[UIView alloc] initWithFrame:toolbarFrame];
    self.toolbar.alpha = 1.000;
    self.toolbar.autoresizesSubviews = YES;
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.toolbar.clearsContextBeforeDrawing = NO;
    self.toolbar.clipsToBounds = YES;
    self.toolbar.contentMode = UIViewContentModeScaleToFill;
    self.toolbar.hidden = NO;
    self.toolbar.multipleTouchEnabled = NO;
    self.toolbar.opaque = NO;
    self.toolbar.userInteractionEnabled = YES;
    self.toolbar.backgroundColor = [CDVWebViewController colorFromRGBA:_options.headBarBg];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage imageNamed:@"ic_back"];
    backButton.bounds = CGRectMake(0, 0, backImage.size.width, backImage.size.height);

    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];

    self.backButton = backButton;
    [self.toolbar addSubview:self.backButton];

    CGFloat titleWidth = CGRectGetWidth(self.view.frame) - backButton.frame.size.width * 2.0f;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(backButton.frame.size.width, 0, titleWidth, toolbarHeight)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.textColor = [CDVWebViewController colorFromRGBA:_options.titleColor];


    [self.toolbar addSubview:self.titleLabel];

    self.view.backgroundColor = [CDVWebViewController colorFromRGBA:_options.headBarBg];
    [self.view addSubview:self.toolbar];
}

- (void)goBack:(id)sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    } else {
        [self close];
    }
}

- (void)close {

    [CDVUserAgentUtil releaseLock:&_userAgentLockToken];
    self.currentURL = nil;

    if ((self.navigationDelegate != nil) && [self.navigationDelegate respondsToSelector:@selector(browserExit)]) {
        [self.navigationDelegate browserExit];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self respondsToSelector:@selector(presentingViewController)]) {
            [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        } else {
            [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

- (void)reload {
    [self.webView reload];
}

- (void)navigateTo:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    if (_userAgentLockToken != 0) {
        [self.webView loadRequest:request];
    } else {
        [CDVUserAgentUtil acquireLock:^(NSInteger lockToken) {
            _userAgentLockToken = lockToken;
            [CDVUserAgentUtil setUserAgent:_userAgent lockToken:lockToken];
            [self.webView loadRequest:request];
        }];
    }
}

- (void)showLocationBar {

}

- (void)showToolBar {

}

+ (UIColor *)colorFromRGBA:(NSString *)rgba {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self.webView loadHTMLString:nil baseURL:nil];
    [CDVUserAgentUtil releaseLock:&_userAgentLockToken];
    [super viewDidUnload];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.orientationDelegate supportedInterfaceOrientations];
    }

    return 1 << UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.orientationDelegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }

    return YES;
}

- (BOOL)shouldAutorotate {
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotate)]) {
        return [self.orientationDelegate shouldAutorotate];
    }
    return YES;
}

@end