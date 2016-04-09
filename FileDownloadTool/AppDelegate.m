//
//  AppDelegate.m
//  FileDownloadTool
//
//  Created by dito on 16/4/7.
//  Copyright © 2016年 zouzhigang. All rights reserved.
//

#import "AppDelegate.h"
#import "LPFileDownloadManager.h"
#import "ViewController.h"
#import "LPFileManager.h"
#import "LPDownloadModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    
    [[LPFileDownloadManager sharedFileDownloadManager] startAllDownload];
    
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    return YES;
}

void UncaughtExceptionHandler(NSException *exception) {
    //存储崩溃数据
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *models = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithFile:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:kModelKey]];
        for (LPDownloadModel *model in models) {
            if (model.downloadState != FileDownloadStateFinish &&
                model.downloadState != FileDownloadStateSuspending) {
//                [[LPFileDownloadManager sharedFileDownloadManager] suspendDownloadWithModel:model];
                model.downloadState = FileDownloadStateSuspending;
                [model updateItem];
            }
        }        
    });

    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    
    NSLog(@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name, reason, arr);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *models = [LPFileManager getDataAtFilePath:kModelKey];
        for (LPDownloadModel *model in models) {
            if (model.downloadState != FileDownloadStateFinish &&
                model.downloadState != FileDownloadStateSuspending) {
                [[LPFileDownloadManager sharedFileDownloadManager] suspendDownloadWithModel:model];
//                downloadModel.downloadState = FileDownloadStateSuspending;
            }
        }
    });


}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
