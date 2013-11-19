//
//  Spawner.m
//  Flubble
//
//  Created by Johan Ismael on 11/17/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "Spawner.h"
#import "IncompleteCircleNode.h"

#define BALL_WIDTH 50
#define BALL_GLOW_WIDTH 5.0

#define FLUBBLE_WIDTH 10
#define FLUBBLE_GLOW_WIDTH 2.0

static const uint32_t flubbleCategory = 0x1 << 0;
static const uint32_t enemyCategory = 0x1 << 1;

@implementation Spawner

+ (SKNode *)flubble
{
    SKShapeNode *node = [[SKShapeNode alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, FLUBBLE_WIDTH, FLUBBLE_WIDTH)];
    node.path = [path CGPath];
    node.fillColor = [SKColor whiteColor];
    node.strokeColor = [SKColor whiteColor];
    node.glowWidth = FLUBBLE_GLOW_WIDTH;
    
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:FLUBBLE_WIDTH/2];
    node.physicsBody.categoryBitMask = flubbleCategory;
    node.physicsBody.contactTestBitMask = enemyCategory;
    node.physicsBody.collisionBitMask = 0;
    return node;
}

+ (SKNode *)planet
{
    SKShapeNode *node = [[SKShapeNode alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, BALL_WIDTH, BALL_WIDTH)];
    node.path = [path CGPath];
    node.fillColor = [SKColor redColor];
    node.strokeColor = [SKColor redColor];
    node.glowWidth = BALL_GLOW_WIDTH;
    
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:BALL_WIDTH/2];
    node.physicsBody.categoryBitMask = flubbleCategory;
    node.physicsBody.contactTestBitMask = enemyCategory;
    node.physicsBody.collisionBitMask = 0;
    return node;
}

+ (SKNode *)enemyCircleWithStartingRadius:(CGFloat)radius
{
    IncompleteCircleNode *node = [[IncompleteCircleNode alloc] initWithStartingRadius:radius
                                                                             holeSize:M_PI/2];
    node.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:node.path];
    node.physicsBody.categoryBitMask = enemyCategory;
    node.physicsBody.contactTestBitMask = flubbleCategory;
    
    return node;
}

@end
