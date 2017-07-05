#import "ViewController.h"
#import "EAGLView.h"
#import <ReplayKit/ReplayKit.h>


#define DEG2RAD (M_PI/180.0f)
#define AnimationDuration (0.3)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


enum {
	BUTTON_BRIGHTNESS,
	BUTTON_CONTRAST,
	BUTTON_SATURATION,
	BUTTON_HUE,
	BUTTON_SHARPNESS,
	NUM_BUTTONS
};

@interface ViewController()<RPPreviewViewControllerDelegate,RPBroadcastActivityViewControllerDelegate,RPBroadcastControllerDelegate>

@property(nonatomic, strong)RPBroadcastController * broadcastController;
@property (nonatomic, weak)   UIView   *cameraPreview;
@property (nonatomic, assign) BOOL allowLive;

@end

@implementation ViewController

@synthesize slider;
@synthesize tabBar;
@synthesize replayBtn;
@synthesize liveBtn;

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //3d touch 和 corespotlight的跳转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionWithShortcutItem:) name:@"Notice3DTouch" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionWithSportLight:) name:@"NoticeSpotlight" object:nil];
    
    
}

- (void)viewDidLoad
{
	int b, i;

	// Select first tab by default
	tabBar.selectedItem = [tabBar.items objectAtIndex:0];
	
	// Create a bitmap context for rendering the tabBar buttons
	// Usually, button images are loaded from disk, but these simple shapes can be procedurally generated.
	// UITabBar only needs the alpha channel of these images.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil, 30, 30, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
	CGImageRef theCGImage;

	// Draw with white round strokes
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
	
	for (b = 0; b < NUM_BUTTONS; b++)
	{
		CGContextClearRect(context, CGRectMake(0, 0, 30, 30));

		switch(b)
		{
			case BUTTON_BRIGHTNESS:
			{
				const CGFloat line[8*4] = {
					15.0, 6.0, 15.0, 4.0,
					15.0,24.0, 15.0,26.0,
					 6.0,15.0,  4.0,15.0,
					24.0,15.0, 26.0,15.0,
					21.5,21.5, 23.0,23.0,
					 8.5, 8.5,  7.0, 7.0,
					21.5, 8.5, 23.0, 7.0,
					 8.5,21.5,  7.0,23.0,					
				};
			
				// A circle with eight rays around it
				CGContextStrokeEllipseInRect(context, CGRectMake(10.5, 10.5, 9.0, 9.0));
				for (i = 0; i < 8; i++)
				{
					CGContextMoveToPoint(context, line[i*4+0], line[i*4+1]);
					CGContextAddLineToPoint(context, line[i*4+2], line[i*4+3]);
					CGContextStrokePath(context);					
				}
				break;
			}
			case BUTTON_CONTRAST:
			{
				// A circle with the right half filled
				CGContextStrokeEllipseInRect(context, CGRectMake(4.0, 4.0, 22.0, 22.0));
				CGContextAddArc(context, 15.0, 15.0, 11.0, -M_PI/2.0, M_PI/2.0, false);
				CGContextFillPath(context);
				break;
			}
			case BUTTON_SATURATION:
			{
				CGGradientRef gradient;
				const CGFloat stripe[3][12] = {
					{ 0.3,0.3,0.3,0.15, 1.0,0.0,0.0,0.70,  5, 5, 7, 25 }, 
					{ 0.5,0.5,0.5,0.25, 0.0,1.0,0.0,0.75, 12, 5, 6, 25 },
					{ 0.2,0.2,0.2,0.10, 0.0,0.0,1.0,0.65, 18, 5, 7, 25 },
				};

				// Red/Green/Blue gradients, inside a rounded rect
				for (i = 0; i < 3; i++)
				{
					gradient = CGGradientCreateWithColorComponents(colorSpace, stripe[i], NULL, 2);
					CGContextSaveGState(context);
					CGContextClipToRect(context, CGRectMake(stripe[i][8], stripe[i][9], stripe[i][10], stripe[i][11]));
					CGContextDrawLinearGradient(context, gradient, CGPointMake(15, 5), CGPointMake(15, 25), 0);
					CGContextRestoreGState(context);
					CGGradientRelease(gradient);
				}

				CGContextMoveToPoint(context, 4, 15);
				CGContextAddArcToPoint(context, 4, 4, 15, 4, 4);
				CGContextAddArcToPoint(context, 26, 4, 26, 15, 4);
				CGContextAddArcToPoint(context, 26, 26, 15, 26, 4);
				CGContextAddArcToPoint(context, 4, 26, 4, 15, 4);
				CGContextClosePath(context);
				CGContextStrokePath(context);
				break;
			}
			case BUTTON_HUE:
			{
				CGGradientRef gradient;
				CGFloat hue[8];
				const int angle = 4;
				
				// A radial gradient, inside a circle
				for (i = 0; i < 360; i+=angle)
				{
					float x = cosf((i+angle*0.5)*DEG2RAD)*10+15;
					float y = sinf((i+angle*0.5)*DEG2RAD)*10+15;
					float r = (i    )/180.0; if (r > 1.0) r = 2.0-r;
					float g = (i+120)/180.0; if (g > 2.0) g = g-2.0; else if (g > 1.0) g = 2.0-g;
					float b = (i+240)/180.0; if (b > 3.0) b = 4.0-b; else if (b > 2.0) b = b-2.0; else b = 2.0-b;
					float a = (i+ 90)/180.0; if (a > 2.0) a = a-2.0; else if (a > 1.0) a = 2.0-a;
					hue[0] = hue[4] = r;
					hue[1] = hue[5] = g;
					hue[2] = hue[6] = b;
					hue[3] = a*0.5;
					hue[7] = a*0.75;

					gradient = CGGradientCreateWithColorComponents(colorSpace, hue, NULL, 2);
					CGContextSaveGState(context);
					CGContextMoveToPoint(context, 15, 15);
					CGContextAddArc(context, 15, 15, 10, i*DEG2RAD, (i+angle)*DEG2RAD, false);
					CGContextClosePath(context);
					CGContextClip(context);
					CGContextDrawLinearGradient(context, gradient, CGPointMake(x, y), CGPointMake(15, 15), 0);					
					CGContextRestoreGState(context);
					CGGradientRelease(gradient);
				}

				CGContextStrokeEllipseInRect(context, CGRectMake(4.0, 4.0, 22.0, 22.0));
				break;
			}
			case BUTTON_SHARPNESS:
			{
				int x, y;
				
				// A gradient checkerboard, inside a rounded rect
				for (x = 5; x < 25; x+=2)
				{
					float b = (x - 5)/19.0*0.5+0.375;
					if (b > 0.75) b = 0.75;
					else if (b < 0.5) b = 0.5;
					
					for (y = 5; y < 25; y+=2)
					{
						float k = ((x ^ y) & 2) ? b : 1.0-b;
						CGContextSetRGBFillColor(context, k, k, k, k);
						CGContextFillRect(context, CGRectMake(x, y, 2, 2));
					}
				}
		
				CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
				CGContextMoveToPoint(context, 4, 15);
				CGContextAddArcToPoint(context, 4, 4, 15, 4, 4);
				CGContextAddArcToPoint(context, 26, 4, 26, 15, 4);
				CGContextAddArcToPoint(context, 26, 26, 15, 26, 4);
				CGContextAddArcToPoint(context, 4, 26, 4, 15, 4);
				CGContextClosePath(context);
				CGContextStrokePath(context);
				break;
			}
		}
		theCGImage = CGBitmapContextCreateImage(context);
		((UITabBarItem *)[tabBar.items objectAtIndex:b]).image = [UIImage imageWithCGImage:theCGImage];
		CGImageRelease(theCGImage);
	}

	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
    
    //
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Notice3DTouch" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NoticeSpotlight" object:nil];
}

- (void)dealloc
{
	self.slider = nil;
	self.tabBar = nil;
    self.replayBtn=nil;
    NSLog(@"销毁观察者");
   
    [liveBtn release];
    [super dealloc];
}
#pragma mark -UI action

- (void)sliderAction:(id)sender
{
	// Redraw the view with the new settings
	[((EAGLView*)self.view) drawView];
}

- (IBAction)replayPressed:(UIButton *)sender {
    
    
    if([self isSystemVersionOK])
    {
        NSString *name=sender.currentTitle;
        
        if([name isEqualToString:@"start"])
        {
            [replayBtn setTitle:@ "stop" forState:UIControlStateNormal];
            [self startRecording];
        }
        else if([name isEqualToString:@"stop"])
        {
             [replayBtn setTitle:@ "start" forState:UIControlStateNormal];
            [self stopRecording];
        }
    }
    else
    {
        NSLog(@"replayKit record can't support");
    }
    
   
}

- (IBAction)livePressed:(UIButton *)sender {
    
    if([self checkSupportLiveAndSet])
    {
        NSString *name=sender.currentTitle;
        
        if([name isEqualToString:@"Live Start"])
        {
            
            [liveBtn setTitle:@"Live Stop" forState:UIControlStateNormal];
            [self liveStart];
            
        }else if([name isEqualToString:@"Live Stop"])
        {
            [liveBtn setTitle:@"Live Start" forState:UIControlStateNormal];
            [self liveFinsh];
        }
    }
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	// Recenter the slider (this application does not accumulate multiple filters)
	[self.slider setValue:1.0 animated:YES];
	// Redraw the view with the new settings
	[((EAGLView*)self.view) drawView];
}

#pragma mark -notification
-(void)actionWithShortcutItem:(NSNotification *)notification
{
    NSString *type = notification.userInfo[@"type"];
    if(type!=nil)
    {
        
        
        //todo some viewcontroller transition
        if([type isEqualToString:@"openHome"])
        {
            tabBar.selectedItem = [tabBar.items objectAtIndex:0];
            
        }
        if([type isEqualToString:@"openPush"])
        {
            tabBar.selectedItem = [tabBar.items objectAtIndex:1];
        }
        if([type isEqualToString:@"openScanner"])
        {
           tabBar.selectedItem = [tabBar.items objectAtIndex:3];
        }
        if([type isEqualToString:@"openSearch"])
        {
            tabBar.selectedItem = [tabBar.items objectAtIndex:4];
        }
        
        
    }
}

-(void)actionWithSportLight:(NSNotification *)notification
{
    NSString* identifier=notification.userInfo[@"identifier"];
    if([identifier isEqualToString:@"homeItem"])
    {
        tabBar.selectedItem=[tabBar.items objectAtIndex:0];
    }
    else if ([identifier isEqualToString:@"newThingsItem"])
    {
        tabBar.selectedItem=[tabBar.items objectAtIndex:1];
     }
}

#pragma mark -replay kit check
-(BOOL)isSystemVersionOK
{
    if([[UIDevice currentDevice].systemVersion floatValue]<9.0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(BOOL)checkSupportRecording
{
    if([[RPScreenRecorder sharedRecorder]isAvailable])
    {
        return YES;
    }
    else{
        return NO;
    }
}

-(BOOL)checkSupportLiveAndSet
{
    self.allowLive=SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0");
    
    if(self.allowLive)
    {
        //使用相机
        [RPScreenRecorder sharedRecorder].cameraEnabled = true;
        //使用麦克风
        [RPScreenRecorder sharedRecorder].microphoneEnabled = true;
    }
    return _allowLive;
}

#pragma mark - alert
-(void)showAlertWithString:(NSString *)message
{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"warning" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)showAlert:(NSString *)title andMessage:(NSString *)message {
    if (!title) {
        title = @"";
    }
    if (!message) {
        message = @"";
    }
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:NO completion:nil];
}
#pragma mark -replaykit delegate
-(void)startRecording
{
    if(![self checkSupportRecording])
        
    {
        [self showAlertWithString:@"can't support record!"];
        return;
    }
    
    //    __weak ViewController *weakSelf=self;
    
    [[RPScreenRecorder sharedRecorder]startRecordingWithHandler:^(NSError *error){
        if(error)
        {
            NSLog(@"wrong meassage %@",error);
            [self showAlertWithString:error.description];
        }
        else
        {

            NSLog(@"start recording");
        }
        
        
    }];
    
    
    
}
-(void)stopRecording
{
    //    __weak ViewController *weakSelf=self;
    [[RPScreenRecorder sharedRecorder]stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        
        if(error)
        {
            NSLog(@"wrong meassage %@",error);
            [self showAlertWithString:error.description];
            
        }
        else{
            
            NSLog(@"show preview");
            previewViewController.previewControllerDelegate=self;
            
            
            [self showVideoPreviewController:previewViewController withAnimation:YES];
        }
        
        
    }];
}

-(void)showVideoPreviewController:(RPPreviewViewController *)previewController withAnimation:(BOOL)animation
{
    
    
    __weak ViewController *weakSelf=self;
    
    //ui change to main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect rect=[UIScreen mainScreen].bounds;
        if(animation)
        {
            rect.origin.x+=rect.size.width;
            previewController.view.frame=rect;
            rect.origin.x-=rect.size.width;
            
            [UIView animateWithDuration:AnimationDuration animations:^(void){
                previewController.view.frame=rect;
            }completion:^(BOOL finished)
             {
                 
             }];
            
            
        }
        else
        {
            previewController.view.frame=rect;
        }
        
        [weakSelf.view addSubview:previewController.view];
        [weakSelf addChildViewController:previewController];
        
        
    });}
//关闭视频预览页面，animation=是否要动画显示
- (void)hideVideoPreviewController:(RPPreviewViewController *)previewController withAnimation:(BOOL)animation {
    
    //UI需要放到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect rect = previewController.view.frame;
        
        if (animation) {
            
            rect.origin.x += rect.size.width;
            [UIView animateWithDuration:AnimationDuration animations:^(){
                previewController.view.frame = rect;
            } completion:^(BOOL finished){
                //移除页面
                [previewController.view removeFromSuperview];
                [previewController removeFromParentViewController];
            }];
            
        } else {
            //移除页面
            [previewController.view removeFromSuperview];
            [previewController removeFromParentViewController];
        }
    });
    
}

#pragma mark - replaykit vedio callback
-(void)previewControllerDidFinish:(RPPreviewViewController *)previewController
{
    [self hideVideoPreviewController:previewController withAnimation:YES];
}

-(void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet<NSString *> *)activityTypes
{
    __weak ViewController *weakSelf=self;
    if ([activityTypes containsObject:@"com.apple.UIKit.activity.SaveToCameraRoll"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAlert:@"保存成功" andMessage:@"已经保存到系统相册"];
        });
    }
    if ([activityTypes containsObject:@"com.apple.UIKit.activity.CopyToPasteboard"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAlert:@"复制成功" andMessage:@"已经复制到粘贴板"];
        });
    }
}

#pragma mark -replaykit live 

-(void)liveStart
{
    __weak ViewController* weakSelf=self;
    
    if(![RPScreenRecorder sharedRecorder].isRecording)
    {
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"%@",error);
                return;
            }
            broadcastActivityViewController.delegate=weakSelf;
            broadcastActivityViewController.modalPresentationStyle=UIModalPresentationPopover;
            
            //ipad适配
            if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
            {
                broadcastActivityViewController.popoverPresentationController.sourceRect = weakSelf.liveBtn.frame;
                broadcastActivityViewController.popoverPresentationController.sourceView=weakSelf.liveBtn;
                
            }
            
            
            [weakSelf presentViewController:broadcastActivityViewController animated:true completion:^{
                
            }];
            
        }];
        
    }
    else{
        //断开当前链接
        [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
            
            
        }];
    }

}

-(void)liveFinsh
{
    __weak ViewController *weakSelf=self;
    [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"finishBroadcastWithHandler %@",error);
        }
        
        //移除摄像头
        [weakSelf.cameraPreview removeFromSuperview];
        
        
    }];
}

-(void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(RPBroadcastController *)broadcastController error:(NSError *)error{
    
    
    if (error) {
        NSLog(@"didFinishWithBroadcastController with error %@",error);
    }
    [broadcastActivityViewController dismissViewControllerAnimated:true completion:nil];
    
    self.broadcastController = broadcastController;
    
    
    __weak ViewController* weakSelf=self;
    if(!error)
    {
        [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
            
            NSLog(@"broadcastControllerHandler");
            if(!error)
            {
                
                weakSelf.broadcastController.delegate=self;
                UIView* cameraView = [[RPScreenRecorder sharedRecorder] cameraPreviewView];
                weakSelf.cameraPreview=cameraView;
                if(cameraView)
                {
                    cameraView.frame=CGRectMake(0, 0, 200, 200);
                    [weakSelf.view addSubview:cameraView];
                    
                    
                    
                }
                
                
            }
            else{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                         message:error.localizedDescription
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:nil]];
                
                [self presentViewController:alertController
                                   animated:YES
                                 completion:nil];
            }
        }];
        
        
    }
    else{
        NSLog(@"Error returning from Broadcast Activity: %@", error);
    }
    
    
    
}
@end
