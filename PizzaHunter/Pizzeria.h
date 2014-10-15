//
//  Pizzeria.h
//  PizzaHunter
//
//  Created by Taylor Wright-Sanson on 10/15/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Pizzeria : MKMapItem

- (instancetype)initWithMapItem: (MKMapItem *)mkMapItem;

@property (readonly) NSString *address;
@property (readonly) NSString *distance;
@property (readonly) CLLocation *location;

@property CLLocationDistance distanceFromCurrentLocation;
@property NSString *distanceFromCurrentLocationInMilesString;
@property double distanceFromCurrentLocationInMilesDouble;


@end
