//
//  MyScene.m
//  Flubble
//
//  Created by Johan Ismael on 11/10/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "MyScene.h"
#import "Spawner.h"
#import "IncompleteCircleNode.h"
#import "FlubbleConstants.h"
#import "GameOverScene.h"
@import AVFoundation;


@interface MyScene ()

@property (nonatomic, strong) NSMutableArray *enemies;
@property (nonatomic, strong) AVPlayer *bgVideoPlayer;

//FLUBBLE
@property (nonatomic, strong) SKNode *flubbleNode;
@property (nonatomic, assign) CGFloat flubbleTheta;
@property (nonatomic, assign) CGFloat flubbleOrbitRadius;
@property (nonatomic, assign) CGPoint flubbleSpeed;

//PLANET
@property (nonatomic, strong) SKNode *planetNode;

//HUD
@property (nonatomic, assign) CFTimeInterval initialTime;
@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, strong) SKLabelNode *scoreNode;
@property (nonatomic, assign) NSUInteger livesCount;

@end

@implementation MyScene

#define SCORE_LABEL_OFFSET 10

- (SKLabelNode *)scoreNode
{
    if (!_scoreNode) {
        _scoreNode = [[SKLabelNode alloc] initWithFontNamed:@"Avenir-Light"];
        _scoreNode.position = CGPointMake(-self.size.width/2 + SCORE_LABEL_OFFSET,-self.size.height/2 + SCORE_LABEL_OFFSET);
        _scoreNode.fontColor = [SKColor whiteColor];
        _scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        [self addChild:_scoreNode];
    }
    return _scoreNode;
}

- (void)setScore:(NSUInteger)score
{
    _score = score;
    self.scoreNode.text = [NSString stringWithFormat:@"Score %lu", (unsigned long)score];
}

#define FLUBBLE_BALL_OFFSET 50

- (NSMutableArray *)enemies
{
    if (!_enemies) {
        _enemies = [[NSMutableArray alloc] init];
    }
    return _enemies;
}

#pragma mark - Background Video

- (AVPlayer *)bgVideoPlayer
{
    if (!_bgVideoPlayer) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"black_bg" ofType:@"mp4"]];
        _bgVideoPlayer = [[AVPlayer alloc] initWithURL:url];
        _bgVideoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bgVideoDidEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[_bgVideoPlayer currentItem]];
    }
    return _bgVideoPlayer;
}

- (void)bgVideoDidEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)willMoveFromView:(SKView *)view
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"contact detected");
    
    SKNode *firstNode = contact.bodyA.node;
    SKNode *secondNode = contact.bodyB.node;
    
    SKNode *enemy;
    if (firstNode.physicsBody.categoryBitMask == enemyCategory) {
        enemy = firstNode;
    }
    
    if (secondNode.physicsBody.categoryBitMask == enemyCategory) {
        enemy = secondNode;
    }
    
    [enemy removeFromParent];
    self.livesCount--;
    if (self.livesCount == 0) [self transitionToGameOver];
}

- (void)transitionToGameOver
{
    SKTransition *transition = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    transition.pausesOutgoingScene = YES;
    GameOverScene *goScene = [[GameOverScene alloc] initWithSize:self.size];
    [self.scene.view presentScene:goScene
                       transition:transition];
}

- (void)didMoveToView:(SKView *)view
{
    [view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
}

- (void)setup
{
    self.anchorPoint = CGPointMake(0.5, 0.5);
    self.flubbleTheta = 0;
    self.score = 0;
    self.initialTime = 0;
    self.livesCount = 3;
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self setup];
        
        //VIDEO BACKGROUND
        SKVideoNode *videoNode = [[SKVideoNode alloc] initWithAVPlayer:self.bgVideoPlayer];
        videoNode.size = self.size;
        videoNode.zPosition = -1;
        [self addChild:videoNode];
        [videoNode play];
        
        //PLANET
        self.planetNode = [Spawner planet];
        self.planetNode.position = CGPointMake(-[self planetWidth]/2, -[self planetWidth]/2);
        [self addChild:self.planetNode];
        
        //Emitter node
        NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
        SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
        [self.planetNode addChild:emitterNode];
        emitterNode.position = CGPointMake([self planetWidth]/2, [self planetWidth]/2);
        
        
        //FLUBBLE
        self.flubbleNode = [Spawner flubble];
        [self.planetNode addChild:self.flubbleNode];
        self.flubbleOrbitRadius = [self planetWidth]/2 + FLUBBLE_BALL_OFFSET/2 + [self flubbleWidth]/2;

        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self
                                       selector:@selector(addEnemy:)
                                       userInfo:nil
                                        repeats:YES];
    }
    return self;
}

- (void)addEnemy:(NSTimer *)timer
{
    SKNode *newEnemy = [Spawner enemyCircleWithStartingRadius:self.size.width];
    [self.enemies addObject:newEnemy];
    [self addChild:newEnemy];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    self.flubbleSpeed = [gesture velocityInView:self.view];
}

- (void)didEvaluateActions {
}

- (void)didSimulatePhysics {
}

#define DECELERATION_FACTOR 1.1
#define GESTURE_TO_SPEED_FACTOR 2000

-(void)update:(CFTimeInterval)currentTime {
    if (self.initialTime == 0) {
        self.initialTime = currentTime;
    }
    self.score = currentTime - self.initialTime;
    
    //UPDATE FLUBBLE BASED ON GESTURE
    self.flubbleSpeed = CGPointMake(self.flubbleSpeed.x / DECELERATION_FACTOR, self.flubbleSpeed.y);
    self.flubbleTheta += self.flubbleSpeed.x/GESTURE_TO_SPEED_FACTOR;
    self.flubbleNode.position = CGPointMake(self.flubbleOrbitRadius*cos(self.flubbleTheta) + [self planetWidth]/2 - [self flubbleWidth]/2,
                                            self.flubbleOrbitRadius*sin(self.flubbleTheta) + [self planetWidth]/2 - [self flubbleWidth]/2);
    
    //UPDATE ENEMIES
    [self.enemies makeObjectsPerformSelector:@selector(update)];
}

#pragma mark - Privates

- (CGFloat)flubbleWidth
{
    return self.flubbleNode.frame.size.width;
}

- (CGFloat)planetWidth
{
    return self.planetNode.frame.size.width;
}

@end
