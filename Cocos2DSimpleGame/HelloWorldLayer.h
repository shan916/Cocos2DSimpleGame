//
//  HelloWorldLayer.h
//  Cocos2DSimpleGame
//
//  Created by Zeeshan Khaliq on 8/20/13.
//  Copyright Zeeshan Khaliq 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
