//
//  WKWebViewController.m
//  MyDemo
//
//  Created by spartawhy on 2017/7/7.
//
//

#import "WKWebViewController.h"


@interface WKWebViewController ()

@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)UIActivityIndicatorView *activityIndicator;

@end

@implementation WKWebViewController

@synthesize wkWebView;


#pragma mark -life circle

-(void)loadView
{
    WKWebViewConfiguration *config=[[WKWebViewConfiguration alloc]init];
    config.preferences.minimumFontSize=18;
    
    wkWebView=[[WKWebView alloc]initWithFrame:[[UIScreen mainScreen]bounds] configuration:config];
    wkWebView.navigationDelegate=self;
    
    self.view=wkWebView;
    //[wkWebView release];
    
    NSLog(@"loadview");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    
    
    _activityIndicator=[[UIActivityIndicatorView alloc]init];
    _activityIndicator.center=self.view.center;
    _activityIndicator.hidesWhenStopped=true;
    _activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    
    [self.view addSubview:_activityIndicator];
    
    
    NSLog(@"viewdidload");
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - public method
-(void)OpenUrl:(NSString *)url
{
    self.url=url;
    NSLog(@"url set");
}


#pragma -mark WKNavigatonDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    [self showActivityIndicator:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
   [UIApplication sharedApplication].networkActivityIndicatorVisible=FALSE;
    [self showActivityIndicator:FALSE];
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self showActivityIndicator:FALSE];
    NSLog(@"%@",error.description);
}

#pragma mark -ActivityIndicator

-(void) showActivityIndicator:(BOOL)show
{
    if (show)
    {
        [_activityIndicator startAnimating];
    }else{
        
        [_activityIndicator stopAnimating];
    }
}

@end
