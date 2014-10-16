//
//  ViewController.m
//  PizzaHunter
//
//  Created by Taylor Wright-Sanson on 10/15/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//
#define METERS_TO_MILES 0.000621371192

#import "PizzeriaListViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Pizzeria.h"

@interface PizzeriaListViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property MKRoute *routeDetails;
@property NSTimeInterval pizzeriaCrawlTime;
@property (weak, nonatomic) IBOutlet UILabel *pizzeriaCrawlTimeLabel;

@end

@implementation PizzeriaListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - TableView Delegate 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pizzerias.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    if (self.pizzerias.count)
    {
        Pizzeria *pizzeria = [self.pizzerias objectAtIndex:indexPath.row];
        // If pizzeria distance is within range show it. We want it closer than 6.21371 miles or 10 kilometers
        cell.textLabel.text = pizzeria.name;
        cell.detailTextLabel.text = pizzeria.distanceFromCurrentLocationInMilesString;
    }

    return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50.0)];
//    footerView.backgroundColor=[UIColor blueColor];
//
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width * .9, 45)];
//
//    label.translatesAutoresizingMaskIntoConstraints = NO;
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor=[UIColor whiteColor];
//    label.text = @"Hello";
//
//    [footerView addSubview:label];
//
//    NSLayoutConstraint *titleLeadingConstraint = [NSLayoutConstraint constraintWithItem:label
//                                                            attribute:NSLayoutAttributeTop
//                                                            relatedBy:NSLayoutRelationEqual
//                                                               toItem:footerView
//                                                            attribute:NSLayoutAttributeBottom
//                                                           multiplier:0.25
//                                                             constant:0.0];
//
//    [footerView addConstraint:[NSLayoutConstraint constraintWithItem:label
//                                                          attribute:NSLayoutAttributeCenterX
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:footerView
//                                                          attribute:NSLayoutAttributeCenterX
//                                                         multiplier:1.0
//                                                           constant:0.0]];
//
//    //it constrain means: "self view Leading edge equal to self.imageCarouselScrollView Trailing + offset 20 "
//    [footerView addConstraint:titleLeadingConstraint];
//
//
//
//    return footerView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 50.0f;
//}

#pragma mark - Core Location

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed to get location: %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            [self reverseGeocode:location];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void)reverseGeocode: (CLLocation *)location
{
    CLGeocoder *geocoder = [CLGeocoder new];

    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        [self findPizzeriaNear:placemark.location];
    }];
}

- (void)findPizzeriaNear: (CLLocation *)usersLocation
{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(usersLocation.coordinate, MKCoordinateSpanMake(1, 1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    // Add pizzerias to aray
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [self loadPizzeriasFromLocalSearchResponse:response location:usersLocation numberOfPizzeriasToDisplay:4 range:6.21371];
        [self calculatePizzeriaCrawlTime:usersLocation];
        [self.tableView reloadData];
    }];
}

- (void)loadPizzeriasFromLocalSearchResponse: (MKLocalSearchResponse *)response
                                    location:(CLLocation *)location
                  numberOfPizzeriasToDisplay:(int)numberOfPizzeriasToDisplay
                                       range:(double)range
{
    self.pizzerias = [[NSMutableArray alloc] init];

    for (MKMapItem *mapItem in response.mapItems)
    {
        Pizzeria *pizzeria = [[Pizzeria alloc] initWithMapItem:mapItem];
        pizzeria.distanceFromCurrentLocation = [location distanceFromLocation:pizzeria.location];
        pizzeria.distanceFromCurrentLocationInMilesDouble = pizzeria.distanceFromCurrentLocation * METERS_TO_MILES;

        if (numberOfPizzeriasToDisplay > 0 && pizzeria.distanceFromCurrentLocationInMilesDouble < range)
        {
            pizzeria.distanceFromCurrentLocationInMilesString = [NSString stringWithFormat:@"%.2f mi", pizzeria.distanceFromCurrentLocation * METERS_TO_MILES];
            NSLog(@"miles: %f", pizzeria.distanceFromCurrentLocation * 0.000621371192);

            [self.pizzerias addObject:pizzeria];
        }

        numberOfPizzeriasToDisplay --;
    }
}

- (void)calculatePizzeriaCrawlTime:(CLLocation *)usersLocation
{
    if (self.pizzerias.count)
    {
        self.pizzeriaCrawlTime = 0;
        MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
        directionsRequest.transportType = MKDirectionsTransportTypeWalking;
        MKMapItem *location = [MKMapItem mapItemForCurrentLocation];

        for (Pizzeria *pizzeria in self.pizzerias)
        {
            [directionsRequest setSource:location];
            [directionsRequest setDestination:pizzeria];

            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
            [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
                self.pizzeriaCrawlTime += (response.expectedTravelTime / 60) + 50;
                // Make time look like 5h14 where h = hours.
                self.pizzeriaCrawlTimeLabel.text = [[NSString stringWithFormat:@"Pizza Crawl Time: %.2f", self.pizzeriaCrawlTime / 60] stringByReplacingOccurrencesOfString:@"." withString:@"h"];
            }];
            location = pizzeria;
        }
    }
}


@end
