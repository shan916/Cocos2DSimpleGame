//
//  GameOverLayer.h
//  Cocos2DSimpleGame
//
//  Created by Zeeshan Khaliq on 8/23/13.
//  Copyright 2013 Zeeshan Khaliq. All rights reserved.
//

#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor

+ (CCScene *)sceneWithWon:(BOOL)won;
- (id)initWithWon:(BOOL)won;

@end
