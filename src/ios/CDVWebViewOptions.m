//
// Created by luocongqiu on 16/9/13.
//

#import "CDVWebViewOptions.h"


@implementation CDVWebViewOptions

- (id)init {
    self = [super init];
    if (self) {
        self.headBarBg = @"#CCCCCC";
        self.titleColor = @"#FFFFFF";
        self.headBarHeight = 44.0;
    }
    return self;
}

@end