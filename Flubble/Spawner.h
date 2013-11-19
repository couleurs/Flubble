//
//  Spawner.h
//  Flubble
//
//  Created by Johan Ismael on 11/17/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Spawner : NSObject

+ (SKNode *)flubble;
+ (SKNode *)planet;
+ (SKNode *)enemyCircleWithStartingRadius:(CGFloat)radius;

@end
