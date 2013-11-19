//
//  IncompleteCircleNode.h
//  Flubble
//
//  Created by Johan Ismael on 11/18/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface IncompleteCircleNode : SKShapeNode

- (instancetype)initWithStartingRadius:(CGFloat)radius
                              holeSize:(CGFloat)holeAngleWidth; //angle in radians
- (void)update;

@end
