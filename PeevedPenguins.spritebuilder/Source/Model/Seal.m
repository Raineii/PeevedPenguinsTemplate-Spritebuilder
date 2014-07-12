//
//  Seal.m
//  PeevedPenguins
//
//  Created by Pollo on 11/07/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

/*-(instancetype)init{
    
    self = [super init];
    
    if(self){
        CCLOG(@"Seal created");
    }
    
    return self;
}*/

-(void)didLoadFromCCB{
    
    //To identify seals when they participate in a collision.
    self.physicsBody.collisionType = @"seal";
}

@end
