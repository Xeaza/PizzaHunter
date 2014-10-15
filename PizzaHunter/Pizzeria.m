//
//  Pizzeria.m
//  PizzaHunter
//
//  Created by Taylor Wright-Sanson on 10/15/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//

#import "Pizzeria.h"

@implementation Pizzeria
{
    MKMapItem *mapItem;
}

- (instancetype)initWithMapItem: (MKMapItem *)mkMapItem
{
    self = [super init];
    if (self)
    {
        mapItem = mkMapItem;
    }
    return self;
}

- (NSString *)address
{
    NSString *addressFromPlaceHolder = [NSString stringWithFormat:@"%@ %@ \n%@",
                         mapItem.placemark.subThoroughfare,
                         mapItem.placemark.thoroughfare,
                         mapItem.placemark.locality];
    return addressFromPlaceHolder;
}

- (MKPlacemark *)placemark
{
    return mapItem.placemark;
}

- (BOOL)isCurrentLocation
{
    return mapItem.isCurrentLocation;
}

- (NSString *)name
{
    return mapItem.name;
}

- (NSString *)phoneNumber
{
    return mapItem.phoneNumber;
}

- (NSURL *)url
{
    return mapItem.url;
}

- (CLLocation *)location
{
    //mapItem.placemark.coordinate
    CLLocation *pizzeraLocation = [[CLLocation alloc] initWithLatitude:mapItem.placemark.coordinate.latitude longitude:mapItem.placemark.coordinate.longitude];

    return pizzeraLocation;
}

@end
