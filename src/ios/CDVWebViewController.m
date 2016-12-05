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

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _spinner.backgroundColor = [UIColor grayColor];
    _spinner.alpha = 0.5;
    _spinner.layer.cornerRadius = 6;
    _spinner.autoresizesSubviews = YES;
    _spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    _spinner.clearsContextBeforeDrawing = NO;
    _spinner.clipsToBounds = NO;
    _spinner.frame = CGRectMake(0, 0, 60.0, 60.0);
    [_spinner setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
    _spinner.hidesWhenStopped = YES;
    _spinner.multipleTouchEnabled = NO;
    _spinner.opaque = NO;
    _spinner.userInteractionEnabled = NO;
    [_spinner stopAnimating];

    _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.view.frame.size.width - 10, self.view.frame.size.height)];
    _errorLabel.adjustsFontSizeToFitWidth = NO;
    _errorLabel.clearsContextBeforeDrawing = YES;
    _errorLabel.clipsToBounds = YES;
    _errorLabel.hidden = YES;

    _errorLabel.numberOfLines = 0;
    _errorLabel.multipleTouchEnabled = NO;
    _errorLabel.opaque = NO;
    _errorLabel.textAlignment = NSTextAlignmentCenter;
    _errorLabel.userInteractionEnabled = NO;

    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;

    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, _options.headBarHeight, self.view.frame.size.width, self.view.frame.size.height - _options.headBarHeight)];
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.webView.delegate = _webViewDelegate;
    self.webView.backgroundColor = [UIColor whiteColor];

    self.webView.clearsContextBeforeDrawing = YES;
    self.webView.clipsToBounds = YES;
    self.webView.contentMode = UIViewContentModeScaleToFill;
    self.webView.multipleTouchEnabled = YES;
    self.webView.opaque = YES;
    self.webView.scalesPageToFit = NO;
    self.webView.userInteractionEnabled = YES;

    CGRect toolbarFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, _options.headBarHeight + statusBarHeight);

    self.toolbar = [[UIView alloc] initWithFrame:toolbarFrame];
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

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, statusBarHeight, _options.headBarHeight, _options.headBarHeight);
    closeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    [closeButton setImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeWebView:) forControlEvents:UIControlEventTouchUpInside];

    self.closeButton = closeButton;
    [self.toolbar addSubview:self.closeButton];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(closeButton.frame.size.width, statusBarHeight, _options.headBarHeight, _options.headBarHeight);
    backButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    [backButton setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];

    self.backButton = backButton;
    [self.toolbar addSubview:self.backButton];

    CGFloat titleWidth = CGRectGetWidth(self.view.frame) - backButton.frame.size.width * 2.0f - closeButton.frame.size.width;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(backButton.frame.size.width + closeButton.frame.size.width, statusBarHeight, titleWidth, _options.headBarHeight)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.textColor = [CDVWebViewController colorFromRGBA:_options.titleColor];

    [self.toolbar addSubview:self.titleLabel];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.toolbar];
    [self.view addSubview:_spinner];
    [self.view addSubview:_errorLabel];
}

- (void)closeWebView:(id)sender {
    [self close];
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

+ (UIColor *)colorFromRGBA:(NSString *)rgba {
    unsigned rgbaVal = 0;

    if ([[rgba substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"#"]) {
        rgba = [rgba substringFromIndex:1];
    }

    if (rgba.length < 8) {
        rgba = [NSString stringWithFormat:@"%@ff", rgba];
    }

    NSScanner *scanner = [NSScanner scannerWithString:rgba];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbaVal];

    return [UIColor colorWithRed:(rgbaVal >> 24 & 0xFF) / 255.0f
                           green:(rgbaVal >> 16 & 0xFF) / 255.0f
                            blue:(rgbaVal >> 8 & 0xFF) / 255.0f
                           alpha:(rgbaVal & 0xFF) / 255.0f];
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


- (void)webViewDidStartLoad:(UIWebView *)theWebView {
    _errorLabel.hidden = YES;
    [_spinner startAnimating];
    return [self.navigationDelegate webViewDidStartLoad:theWebView];
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL isTopLevelNavigation = [request.URL isEqual:[request mainDocumentURL]];
    if (isTopLevelNavigation) {
        self.currentURL = request.URL;
    }
    return [self.navigationDelegate webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {

    self.titleLabel.text = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];

    [_spinner stopAnimating];

    BOOL isPDF = [@"true" isEqualToString:[theWebView stringByEvaluatingJavaScriptFromString:@"document.body==null"]];
    if (isPDF) {
        [CDVUserAgentUtil setUserAgent:_prevUserAgent lockToken:_userAgentLockToken];
    }

    [self.navigationDelegate webViewDidFinishLoad:theWebView];
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error {
    [_spinner stopAnimating];
    _errorLabel.hidden = NO;
    _errorLabel.text = @"加载页面出错";
    [self.navigationDelegate webView:theWebView didFailLoadWithError:error];
}

@end