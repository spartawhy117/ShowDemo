//
//  AppDelegate.m
//  Test
//
//  Created by spartawhy on 2017/6/30.
//  Copyright © 2017年 spartawhy. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        
        [self setCoreSpotlight];
    }
   
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    
    

}




- (void)applicationDidEnterBackground:(UIApplication *)application {
   
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
   
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    

}


- (void)applicationWillTerminate:(UIApplication *)application {
    
}


#pragma mark -quick actions delegate
-(void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notice3DTouch" object:self userInfo:@{ @"type" : shortcutItem.type }];
}

#pragma mark - spotlight delegate
-(BOOL)application:(UIApplication* )application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler
{
    if([userActivity.activityType isEqualToString:CSSearchableItemActionType])
    {
        NSString *identifier=userActivity.userInfo[CSSearchableItemActivityIdentifier];
        
         [[NSNotificationCenter defaultCenter] postNotificationName:@"NoticeSpotlight" object:self userInfo:@{ @"identifier" : identifier }];
        
        
        return YES;
    }
    return NO;
}

#pragma mark -corespotlight
-(void)setCoreSpotlight
{
    //多少个页面就要创建多少个set 每个set对应一个item
    CSSearchableItemAttributeSet *newThingsSet=[[CSSearchableItemAttributeSet alloc]initWithItemContentType:@"newThingsSet"];
    newThingsSet.title=@"新鲜事";
    newThingsSet.contentDescription=@"快捷入口：我的世界-新鲜事";
    newThingsSet.keywords=@[@"新鲜事",@"我的世界",@"MC",@"Minecraft"];
    //todo 设定相关图片
    //newThingsSet.thumbnailData=UIImagePNGRepresentation([UIImage imageNamed:@""]);
    
    CSSearchableItemAttributeSet *homeSet=[[CSSearchableItemAttributeSet alloc]initWithItemContentType:@"homeSet"];
    homeSet.title=@"个人主页";
    homeSet.contentDescription=@"快捷入口：我的世界-个人主页";
    homeSet.keywords=@[@"个人主页",@"我的世界",@"MC",@"Minecraft"];
    
    
    
    //UniqueIdentifier每个搜索都有一个唯一标示，当用户点击搜索到得某个内容的时候，系统会调用代理方法，会将这个唯一标示传给你，以便让你确定是点击了哪一，方便做页面跳转
    //domainIdentifier搜索域标识，删除条目的时候调用的delegate会传过来这个值
    CSSearchableItem *homeItem=[[CSSearchableItem alloc]initWithUniqueIdentifier:@"homeItem" domainIdentifier:@"home" attributeSet:homeSet];
    CSSearchableItem *newThingsItem=[[CSSearchableItem alloc]initWithUniqueIdentifier:@"newThingsItem" domainIdentifier:@"newThings" attributeSet:newThingsSet];
    
    //还可以设置过期时间
    //newThingsItem.expirationDate=[NSDate dateWithTimeIntervalSinceNow:3600];
    
    
    NSArray *itemArray=[NSArray arrayWithObjects:homeItem,newThingsItem, nil];
    [[CSSearchableIndex defaultSearchableIndex]indexSearchableItems:itemArray completionHandler:^(NSError *error)
     {
         if(error)
         {
             NSLog(@"spolight设置失败 %@",error);
         }
         
     }];
    
}

@end
