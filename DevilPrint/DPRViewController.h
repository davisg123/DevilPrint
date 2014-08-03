//
//  DPRViewController.h
//  DevilPrint
//
//  Created by Davis Gossage on 7/20/14.
//  Copyright (c) 2014 Davis Gossage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DPRFileCollectionViewCell.h"

@interface DPRViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,MKMapViewDelegate,DPRFileCollectionViewCellDelegate>

@end
