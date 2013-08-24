//
//  HelloWorldLayer.m
//  Cocos2DSimpleGame
//
//  Created by Zeeshan Khaliq on 8/20/13.
//  Copyright Zeeshan Khaliq 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "SimpleAudioEngine.h"

#import "GameOverLayer.h"

#pragma mark - HelloWorldLayer

NSMutableArray *_monsters;
NSMutableArray *_projectiles;

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
    if ((self = [super initWithColor:ccc4(255, 255, 255, 255)]))
    {
        _monsters = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *player = [CCSprite spriteWithFile:@"player.png"];
        player.position = ccp(player.contentSize.width/2, winSize.height/2);
        [self addChild:player];
        [self schedule:@selector(gameLogic:) interval:1.0];
        [self setTouchEnabled:YES];
        
        [self schedule:@selector(update:)];
    }
    
	return self;
}

- (void)addMonster
{
    CCSprite *monster = [CCSprite spriteWithFile:@"monster.png"];
    
    // Determine where to spawn the monster along the Y axis
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = monster.contentSize.height/2;
    int maxY = winSize.height - monster.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge
    // and along a random position along the Y axis as calculated above
    monster.position = ccp(winSize.width + monster.contentSize.width/2, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 2;
    int maxDuration = 4;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration
                                               position:ccp(-monster.contentSize.width/2, actualY)];
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node)
                                    { [node removeFromParentAndCleanup:YES];
                                        CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
                                        [[CCDirector sharedDirector] replaceScene:gameOverScene];
                                        [_monsters removeObject:node];
                                    }];
    
    [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    // add monster to array
    monster.tag = 1;
    [_monsters addObject:monster];
}

- (void)gameLogic:(ccTime)dt
{
    [self addMonster];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Chose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *projectile = [CCSprite spriteWithFile:@"projectile.png"];
    projectile.position = ccp(20, winSize.height/2);
    
    // Determine offset of location to projectile
    CGPoint offset = ccpSub(location, projectile.position);
    
    // Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    // Ok to add now - we've double checked position
    [self addChild:projectile];
    
    int realX = winSize.width + (projectile.contentSize.width/2);
    float ratio = (float)offset.y / (float)offset.x;
    int realY = (realX * ratio) + projectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far you're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX * offRealX) + (offRealY * offRealY));
    float velocity = 480 / 1; // 480pixels/1sec
    float realMoveDuration = length / velocity;
    
    // Move projectile to actual endpoint
    [projectile runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
      [CCCallBlockN actionWithBlock:^(CCNode *node)
       {
           [node removeFromParentAndCleanup:YES];
           [_projectiles removeObject:node];
       }],
      nil]];
    
    // add projectile to array
    projectile.tag = 2;
    [_projectiles addObject:projectile];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
}

- (void)update:(ccTime)dt
{
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    
    for (CCSprite *projectile in _projectiles)
    {
        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
        for (CCSprite *monster in _monsters)
        {
            if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox))
            {
                [monstersToDelete addObject:monster];
            }
        }
        
        for (CCSprite *monster in monstersToDelete)
        {
            [_monsters removeObject:monster];
            [self removeChild:monster cleanup:YES];
            
            _monstersDestroyed++;
            if (_monstersDestroyed > 30)
            {
                CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }
        }
        
        if (monstersToDelete.count > 0)
        {
            [projectilesToDelete addObject:projectile];
        }
        [monstersToDelete release];
    }
    
    for (CCSprite *projectile in projectilesToDelete)
    {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    
    [projectilesToDelete release];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
    [_monsters release];
    _monsters = nil;
    [_projectiles release];
    _projectiles = nil;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}
@end
