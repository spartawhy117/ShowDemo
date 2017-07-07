//
//  WKWebViewController.h
//  MyDemo
//
//  Created by spartawhy on 2017/7/7.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WKWebViewController : UIViewController<WKNavigationDelegate>

@property (strong,nonatomic)WKWebView *wkWebView;

-(void)OpenUrl:(NSString*)url;
@end
