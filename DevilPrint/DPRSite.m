//
//  DPRSite.m
//  DevilPrint
//
//  Created by Davis Gossage on 7/21/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRSite.h"

@implementation DPRSite

@synthesize directions = _directions;

//annoying that directions can be null, set to an empty string if that's the case
-(void)setDirections:(NSString *)d{
    if ([d isKindOfClass:[NSNull class]]){
        _directions = @"";
    }
    else{
        _directions = d;
    }
}
-(NSString*)directions{
    return _directions;
}

@end
