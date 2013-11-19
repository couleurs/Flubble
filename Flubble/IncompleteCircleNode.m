//
//  IncompleteCircleNode.m
//  Flubble
//
//  Created by Johan Ismael on 11/18/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "IncompleteCircleNode.h"

@interface IncompleteCircleNode()

@property (nonatomic, assign) CGAffineTransform rotation;
@property (nonatomic, assign) CGFloat holeAngleWidth;
@property (nonatomic, assign) CGFloat currentRadius;

@end

@implementation IncompleteCircleNode

- (instancetype)initWithStartingRadius:(CGFloat)radius
                              holeSize:(CGFloat)holeAngleWidth
{
    self = [super init];
    if (self) {
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                            radius:radius
                                                        startAngle:0
                                                          endAngle:2*M_PI - holeAngleWidth
                                                         clockwise:YES];
        self.currentRadius = radius;
        self.holeAngleWidth = holeAngleWidth;
        self.rotation = CGAffineTransformMakeRotation(arc4random());
        [path applyTransform:self.rotation];
        self.path = [path CGPath];
        self.fillColor = [SKColor clearColor];
        self.strokeColor = [SKColor whiteColor];
    }
    return self;
}

#define SHRINK_FACTOR 0.99

- (void)update
{
    self.currentRadius *= SHRINK_FACTOR;
    UIBezierPath *newPath = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                             radius:self.currentRadius
                                                         startAngle:0
                                                           endAngle:2*M_PI - self.holeAngleWidth
                                                          clockwise:YES];
    [newPath applyTransform:self.rotation];
    self.path = [newPath CGPath];
    
    //Update physics body after updating path
    uint32_t categoryBitMask = self.physicsBody.categoryBitMask;
    uint32_t contactTestBitMask = self.physicsBody.contactTestBitMask;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:[newPath CGPath]];
    self.physicsBody.categoryBitMask = categoryBitMask;
    self.physicsBody.contactTestBitMask = contactTestBitMask;
}

@end
