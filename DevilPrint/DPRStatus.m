//
//  DPRStatus.m
//  DevilPrint
//
//  Created by Davis Gossage on 7/21/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import "DPRStatus.h"

@implementation DPRStatus

@synthesize name = _name;
@synthesize image = _image;

-(id)init{
    //default to online
    _image = [UIImage imageNamed:STATUSONLINEIMAGE];
    return [super init];
}

-(void)setName:(NSString *)name{
    _name = name;
    if ([self string:name containsString:@"offline"]){
        _image = [UIImage imageNamed:STATUSOFFLINEIMAGE];
    }
    else if ([self string:name containsString:@"warning"]){
        _image = [UIImage imageNamed:STATUSWARNINGIMAGE];
    }
    else if ([self string:name containsString:@"paper"]){
        _image = [UIImage imageNamed:STATUSPAPERLOWIMAGE];
    }
    else if ([self string:name containsString:@"toner"]){
        _image = [UIImage imageNamed:STATUSTONERLOWIMAGE];
    }
    else if ([self string:name containsString:@"fuser"]){
        _image = [UIImage imageNamed:STATUSTONERLOWIMAGE];
    }
    else if ([self string:name containsString:@"order"]){
        _image = [UIImage imageNamed:STATUSOUTOFORDERIMAGE];
    }
    else if (name.length == 0){
        _image = [UIImage imageNamed:STATUSONLINEIMAGE];
    }
}

-(NSString*)name{
    return _name;
}

-(BOOL)string:(NSString*)string containsString:(NSString*)innerString{
    return [string rangeOfString:innerString options:NSCaseInsensitiveSearch].location == NSNotFound;
}

@end
