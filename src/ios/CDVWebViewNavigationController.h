//
// Created by luocongqiu on 16/9/13.
//

#import <Foundation/Foundation.h>

@protocol CDVScreenOrientationDelegate;

@interface CDVWebViewNavigationController : UINavigationController

@property(nonatomic, weak) id <CDVScreenOrientationDelegate> orientationDelegate;

@end