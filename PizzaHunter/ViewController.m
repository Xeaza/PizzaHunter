//
//  ViewController.m
//  PizzaHunter
//
//  Created by Taylor Wright-Sanson on 10/15/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//
#define METERS_TO_MILES 0.000621371192

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Pizzeria.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *pizzerias;

@end

@implementation ViewController

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

- (void)findPizzeriaNear: (CLLocation *)location
{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    // Add pizzerias to aray
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [self loadPizzeriasFromLocalSearchResponse:response location:location numberOfPizzeriasToDisplay:4 range:6.21371];
        [self.tableView reloadData];
    }];
}

- (void)loadPizzeriasFromLocalSearchResponse: (MKLocalSearchResponse *)response
                                    location:(CLLocation *)location
                  numberOfPizzeriasToDisplay:(int)numberOfPizzeriasToDisplay
                                       range:(double)range
{
    self.pizzerias = [[NSMutableArray alloc] init];

    int numberToDisplay = numberOfPizzeriasToDisplay;
    for (MKMapItem *mapItem in response.mapItems)
    {
        Pizzeria *pizzeria = [[Pizzeria alloc] initWithMapItem:mapItem];
        pizzeria.distanceFromCurrentLocation = [location distanceFromLocation:pizzeria.location];
        pizzeria.distanceFromCurrentLocationInMilesDouble = pizzeria.distanceFromCurrentLocation * METERS_TO_MILES;

        if (numberToDisplay > 0 && pizzeria.distanceFromCurrentLocationInMilesDouble < range)
        {
            pizzeria.distanceFromCurrentLocationInMilesString = [NSString stringWithFormat:@"%.2f mi", pizzeria.distanceFromCurrentLocation * METERS_TO_MILES];
            [self.pizzerias addObject:pizzeria];
        }

        numberToDisplay --;
    }

}


@end
