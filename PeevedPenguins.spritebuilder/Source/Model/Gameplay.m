//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Pollo on 11/07/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "CCPhysics+ObjectiveChipmunk.h" //For the collision handling code


@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    CCNode *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
    
}


//Is called when CCB file has completed loading
-(void)didLoadFromCCB{
    //Tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    //Visualize physics bodies and joints
    _physicsNode.debugDraw = TRUE;
    
    //Make these nodes uncollidable
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
    _physicsNode.collisionDelegate = self;
}

//Called on every touch in this scene
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    //Start catapult dragging when a touch inside of the catapult arm occurs
    if(CGRectContainsPoint([_catapultArm boundingBox], touchLocation)){
        
        //Create a penguin from the ccb-file
        _currentPenguin = [CCBReader load:@"Penguin"];
        
        //Initially position it at the scoop. 34,138 is the position in the node space of the _catapult arm
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace: ccp(34, 138)];
        
        //Transform the world position to the node space to which the penguin will be added (_physicsNode)
        _currentPenguin.position = [_physicsNode convertToWorldSpace:penguinPosition];
        
        //Add it to the physics world
        [_physicsNode addChild:_currentPenguin];
        
        //We don't want the penguin to rotate in the scoop
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        
        //Move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        //Create a joint to keep the penguin fixed to the scoop until the catapult is released
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
        
        //Setup a spring joint between the mouseJointNode and the catapultArm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA: _mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA: ccp(0,0) anchorB: ccp(34,138) restLength:0.f stiffness:3000.f damping:150.f];
    }
    
    //[self launchPenguin];
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    
    //Whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
    //When touches end, meaning the user releases their finger, release the catapult
    [self releaseCatapult];
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    
    //When touches are cancelled, meaning the user drags their finger off the screen or onto something else, release the catapult
    [self releaseCatapult];
}

-(void)releaseCatapult{
    
    if(_mouseJoint != nil){
        //Releases the joint and lets the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        //Releases the joint and lets the penguin fly
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        
        //After snapping rotation is fine
        _currentPenguin.physicsBody.allowsRotation = TRUE;
        
        //Follow the flying penguin
        CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:follow];
    }
}

-(void)launchPenguin{
    //Loads the Penguin.ccb we've set up before in SpriteBuilder
    CCNode *penguin = [CCBReader load:@"Penguin"];
    
    //Position the penguin at the bowl of the catapult
    //penguin.position = ccpAdd(_catapultArm.position, ccp(16, 50));
    penguin.position = ccpAdd(_catapultArm.position, ccp(36, 125));
    
    //Add the penguin to the physics node of this scene (because it has physics enabled)
    [_physicsNode addChild:penguin];
    
    //Manually create and apply a force to launch the penguin
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
    
    self.position = ccp(0,0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    
    //[self runAction:follow];
    [_contentNode runAction:follow];
}

-(void)retry{
    //Reload this level
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA typeB:(CCNode *)nodeB{
    
    CCLOG(@"Something collided with a seal!");
    float energy = [pair totalKineticEnergy];
    CCLOG(@"Energy: %f", energy);
    //If the energy is large enough, remove the seal
    if(energy > 5000.f){
        //In case multiple objects collide with a seal within the same keyframe, addPostStepBlock method from _physics node's space method ensures the sealRemoved method only gets called once. When we call our code inside a block, it only gets called once. Cocos2D will only run one block of code per key and frame.
        [[_physicsNode space] addPostStepBlock:^{[self sealRemoved: nodeA];} key:nodeA];
    }
}

-(void)sealRemoved: (CCNode *)seal{
    
    //Load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"SealExplosion"];
    
    //Make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    
    //Place the particle effect on the seal's position
    explosion.position = seal.position;
    
    //Add the particle effect to the same node the seal is on
    [seal.parent addChild:explosion];
    
    //Finally, remove the destroyed seal
    [seal removeFromParent];
}
@end
