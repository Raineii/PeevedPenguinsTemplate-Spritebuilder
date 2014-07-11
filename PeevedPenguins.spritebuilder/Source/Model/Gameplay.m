//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Pollo on 11/07/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
}


//Is called when CCB file has completed loading
-(void)didLoadFromCCB{
    //Tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
}

//Called on every touch in this scene
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    [self launchPenguin];
}

-(void)launchPenguin{
    //Loads the Penguin.ccb we've set up before in SpriteBuilder
    CCNode *penguin = [CCBReader load:@"Penguin"];
    
    //Position the penguin at the bowl of the catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16, 50));
    
    //Add the penguin to the physics node of this scene (because it has physics enabled)
    [_physicsNode addChild:penguin];
    
    //Manually create and apply a force to launch the penguin
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
}

@end