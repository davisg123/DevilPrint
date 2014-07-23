//
//  DPRSite.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/21/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DPRSite : NSObject

/* sample response
 "id": "133",
 "name": "Art Building",
 "department_id": "13",
 "campus": "East",
 "building": "Art Building",
 "room": "Foyer",
 "directions": "Located by the front reception desk, immediately on the left upon entering the building",
 "latitude": "36.009300",
 "longitude": "-78.917100",
 "retired": "0",
 "created_at": "2012-03-21 12:24:36",
 "updated_at": "2013-10-10 11:23:44",
 "department": "Trinity",
 "computers": false,
 "printers": 1
 */

@property NSString* siteId;
@property NSString* name;
@property NSString* campus;
@property NSString* building;
@property NSString* room;
@property NSString* directions;
@property CLLocation* location;
@property NSString* retired;
@property NSDate* createdAt;
@property NSDate* updatedAt;
@property BOOL computers;
@property int numPrinters;


@end
