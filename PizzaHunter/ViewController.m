//
//  ViewController.m
//  PizzaHunter
//
//  Created by Taylor Wright-Sanson on 10/15/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//

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
        cell.textLabel.text = pizzeria.name;
        cell.detailTextLabel.text = pizzeria.address;
    }
//    else
//    {
//        cell.textLabel.text = @"hi";
//    }
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
        NSString *address = [NSString stringWithFormat:@"%@ %@ \n%@",
                             placemark.subThoroughfare,
                             placemark.thoroughfare,
                             placemark.locality];
        self.textField.text = [NSString stringWithFormat:@"Found you: %@", address];
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
        self.pizzerias = [[NSMutableArray alloc] init];
        for (int i = 0 ; i < 4; i++) {
            Pizzeria *pizzeria = [[Pizzeria alloc] initWithMapItem:[response.mapItems objectAtIndex:i]];
            [self.pizzerias addObject:pizzeria];

        }

        // Uncomment this to have all the response data instated of the above loop that only gives four response items
//        for (MKMapItem *mapItem in response.mapItems)
//        {
//            Pizzeria *pizzeria = [[Pizzeria alloc] initWithMapItem:mapItem];
//            [self.pizzerias addObject:pizzeria];
//        }

        [self.tableView reloadData];
    }];
}


@end
