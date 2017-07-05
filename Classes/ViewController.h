

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController
{
	IBOutlet UISlider *slider;
	IBOutlet UITabBar *tabBar;	
    IBOutlet UIButton *replayBtn;
    IBOutlet UIButton *liveBtn;
}

@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UITabBar *tabBar;
@property (nonatomic,retain) UIButton *replayBtn;
@property (nonatomic,retain) UIButton *liveBtn;

- (IBAction)sliderAction:(id)sender;
- (IBAction)replayPressed:(id)sender;
- (IBAction)livePressed:(id)sender;



@end
