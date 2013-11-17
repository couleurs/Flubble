//
//  MyScene.m
//  Flubble
//
//  Created by Johan Ismael on 11/10/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "MyScene.h"

@interface MyScene ()

@property (nonatomic, strong) SKShapeNode *enemyNode;
@property (nonatomic, assign) CGSize lastEnemySize;
@property (nonatomic, assign) CGFloat lastEnemyRotation;

//FLUBBLE
@property (nonatomic, assign) CGFloat flubbleTheta;
@property (nonatomic, assign) CGFloat flubbleOrbitRadius;
@property (nonatomic, strong) SKShapeNode *flubbleNode;
@property (nonatomic, assign) CGPoint flubbleSpeed;

@end

static const uint32_t flubbleCategory = 0x1 << 0;
static const uint32_t enemyCategory = 0x1 << 1;

@implementation MyScene

#define BALL_WIDTH 50
#define BALL_HEIGHT 50
#define BALL_GLOW_WIDTH 5.0

#define FLUBBLE_WIDTH 10
#define FLUBBLE_HEIGHT 10
#define FLUBBLE_GLOW_WIDTH 2.0

#define FLUBBLE_BALL_OFFSET 50

- (SKShapeNode *)enemyNode
{
    if (!_enemyNode) {
        _enemyNode = [[SKShapeNode alloc] init];
        self.lastEnemySize = CGSizeMake(self.size.width, self.size.width);
        
        UIBezierPath *enemyPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) radius:self.size.width/2 startAngle:0 endAngle:M_PI clockwise:YES];
        self.lastEnemyRotation = arc4random();
        CGAffineTransform rotation = CGAffineTransformMakeRotation(self.lastEnemyRotation);
        [enemyPath applyTransform:rotation];
        
        _enemyNode.path = [enemyPath CGPath];
        _enemyNode.fillColor = [SKColor clearColor];
        _enemyNode.strokeColor = [SKColor whiteColor];
        _enemyNode.position = CGPointMake(0, 0);
        _enemyNode.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:[enemyPath CGPath]];
        _enemyNode.physicsBody.categoryBitMask = enemyCategory;
        _enemyNode.physicsBody.contactTestBitMask = flubbleCategory;
        _enemyNode.physicsBody.friction = 0.0;
        
        [self addChild:_enemyNode];
    }
    return _enemyNode;
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"contact detected");
    [self.enemyNode removeFromParent];
    self.enemyNode = nil;
}

- (void)didMoveToView:(SKView *)view
{
    [view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.flubbleTheta = 0;
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.anchorPoint = CGPointMake(0.5, 0.5);
        
        
        //VIDEO BACKGROUND
        SKVideoNode *videoNode = [[SKVideoNode alloc] initWithVideoFileNamed:@"red_background.mp4"];
        videoNode.size = self.size;
        [self addChild:videoNode];
        [videoNode play];
        
        //BALL
        UIBezierPath *ballPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, BALL_WIDTH, BALL_HEIGHT)];
        UIBezierPath *flubblePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, FLUBBLE_WIDTH, FLUBBLE_HEIGHT)];
        
        SKShapeNode *ballNode = [[SKShapeNode alloc] init];
        ballNode.path = [ballPath CGPath];
        ballNode.fillColor = [SKColor redColor];
        ballNode.strokeColor = [SKColor redColor];
        ballNode.glowWidth = BALL_GLOW_WIDTH;
        ballNode.position = CGPointMake(-BALL_WIDTH/2, -BALL_HEIGHT/2);
        
        self.flubbleNode = [[SKShapeNode alloc] init];
        self.flubbleNode.path = [flubblePath CGPath];
        self.flubbleNode.fillColor = [SKColor whiteColor];
        self.flubbleNode.strokeColor = [SKColor whiteColor];
        self.flubbleNode.glowWidth = FLUBBLE_GLOW_WIDTH;
        self.flubbleOrbitRadius = BALL_WIDTH/2 + FLUBBLE_BALL_OFFSET/2 + FLUBBLE_WIDTH/2;
        [ballNode addChild:self.flubbleNode];
        self.flubbleNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:FLUBBLE_WIDTH/2];
        self.flubbleNode.physicsBody.categoryBitMask = flubbleCategory;
        self.flubbleNode.physicsBody.contactTestBitMask = enemyCategory;
        self.flubbleNode.physicsBody.dynamic = YES;
        self.flubbleNode.physicsBody.friction = 0.0;
        
//        SKPhysicsBody *ballPhysicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ballNode.frame.size.width/2];
//        ballPhysicsBody.mass = 0;
//        ballPhysicsBody.restitution = 1;
//
        //Emitter node
        NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
        SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
        [ballNode addChild:emitterNode];
        emitterNode.position = CGPointMake(BALL_WIDTH/2, BALL_WIDTH/2);

        [self addChild:ballNode];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        videoNode.zPosition = -3;
    }
    return self;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    self.flubbleSpeed = [gesture velocityInView:self.view];
}

- (void)didEvaluateActions {
}

- (void)didSimulatePhysics {
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */

    self.flubbleSpeed = CGPointMake(self.flubbleSpeed.x / 1.1, self.flubbleSpeed.y);
    self.flubbleTheta += self.flubbleSpeed.x/2000;
    self.flubbleNode.position = CGPointMake(self.flubbleOrbitRadius*cos(self.flubbleTheta) + BALL_WIDTH/2 - FLUBBLE_WIDTH/2, self.flubbleOrbitRadius*sin(self.flubbleTheta) + BALL_HEIGHT/2 - FLUBBLE_HEIGHT/2);
    
    if (self.enemyNode.frame.size.width > BALL_WIDTH + BALL_GLOW_WIDTH) {
        self.lastEnemySize = CGSizeMake(self.lastEnemySize.width * 0.99, self.lastEnemySize.height * 0.99);
        UIBezierPath *enemyPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0)
                                                                 radius:self.lastEnemySize.width/2
                                                             startAngle:0
                                                               endAngle:3*M_PI/2
                                                              clockwise:YES];
        CGAffineTransform rotation = CGAffineTransformMakeRotation(self.lastEnemyRotation);
        [enemyPath applyTransform:rotation];
        self.enemyNode.path = [enemyPath CGPath];
        self.enemyNode.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:[enemyPath CGPath]]; //important to keep the hole
        self.enemyNode.physicsBody.categoryBitMask = enemyCategory;
        self.enemyNode.physicsBody.contactTestBitMask = flubbleCategory;
        self.enemyNode.physicsBody.friction = 0.0;
        self.enemyNode.position = CGPointMake(0, 0);
    } else {
        [self.enemyNode removeFromParent];
        self.enemyNode = nil;
    };
}

@end
