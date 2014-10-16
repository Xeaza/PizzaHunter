//
//  MapViewController.m
//  PizzaHunter
//
//  Created by Taylor Wright-Sanson on 10/15/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Pizzeria.h"
#import "PizzeriaListViewController.h"

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property  MKRoute *route;
@property Pizzeria *pizzeria;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    PizzeriaListViewController *pizzeriaListViewController = (PizzeriaListViewController *)self.tabBarController.viewControllers.firstObject;

    for (Pizzeria *pizzeria in pizzeriaListViewController.pizzerias)
    {
        [self.mapView addAnnotation:pizzeria.placemark];
        self.pizzeria = pizzeria;
        // Need to make detail discloser open a segue to a new mapview that loads my locaiton and finds the route to the pizza place i clicked on.
        //[self findRoute];
    }
}

- (IBAction)findRoute
{
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:self.pizzeria.placemark];
    [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeWalking;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            self.route = response.routes.lastObject;
            [self.mapView addOverlay:self.route.polyline];
        }
    }];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:self.route.polyline];
    routeLineRenderer.strokeColor = [UIColor blueColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //[self performSegueWithIdentifier:@"AnnotationSegue" sender:view];
    [self findRoute];
  //  accessoryButtonTappedForRowWithIndexPath
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"HI");
    // TODO - When user taps on specific annotation set the self.pizzeria equal to the pizzeria associated with that annotation
    // then call [self findRoute]; so user can get a route from their location to the pizza place they tapped
//    for (Pizzeria *pizzeria in pizzeriaListViewController.pizzerias)
//    {
//        if (pizzeria.location == view.annotation.coordinate) {
//
//        }
//        [self.mapView addAnnotation:pizzeria.placemark];
//        self.pizzeria = pizzeria;
        // Need to make detail discloser open a segue to a new mapview that loads my locaiton and finds the route to the pizza place i clicked on.
        //[self findRoute];
//    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation)
    {
        return nil;
    }

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.image = [UIImage imageNamed:@"pizza_pin"];

    return pin;
}

//-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
//{
//    CLLocationCoordinate2D center = view.annotation.coordinate;
//
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.01;
//    span.longitudeDelta = 0.01;
//
//    MKCoordinateRegion region;
//    region.center = center;
//    region.span = span;
//
//    [self.mapView setRegion:region animated:YES];
//}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
