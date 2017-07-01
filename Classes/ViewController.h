

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController
{
	IBOutlet UISlider *slider;
	IBOutlet UITabBar *tabBar;	
    IBOutlet UIButton *replayBtn;
}

@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UITabBar *tabBar;
@property (nonatomic,retain) UIButton *replayBtn;


- (IBAction)sliderAction:(id)sender;
- (IBAction)replayPressed:(id)sender;



@end
