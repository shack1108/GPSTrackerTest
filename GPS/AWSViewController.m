//
//  AWSViewController.m
//  GPS
//
//  Created by Andrew Shackelford on 3/28/14.
//  Copyright (c) 2014 Andrew Shackelford Media. All rights reserved.
//

#import "AWSViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface AWSViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
@property (weak, nonatomic) IBOutlet UILabel *speed;
@property (weak, nonatomic) IBOutlet UILabel *distance;
- (IBAction)startWorkout:(id)sender;
- (IBAction)pauseWorkout:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *startWorkoutButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseWorkoutButton;
@property (weak, nonatomic) IBOutlet UILabel *workoutTime;


@end



@implementation AWSViewController {
    CLLocationManager *manager;
    CLLocation *startingLocation;
    NSString *distanceTraveled;
    NSString *distanceTraveledWithAltitude;
    float distanceTraveledNumber;
    float distanceTraveledWithAltitudeNumber;
    CLLocation *pausedLocation;
    CLLocation *restartingPausedLocation;
    BOOL workoutPaused;
    CLLocationDistance distancePausedTraveled;
    NSDate *workoutStartDate;
    NSDate *currentDate;
    NSDate *datePaused;
    NSTimeInterval secondsSinceWorkoutStart;
    NSTimeInterval secondsPaused;
    NSTimeInterval secondsSinceWorkoutStartWhenPaused;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (!manager) manager = [[CLLocationManager alloc] init];
    
    [_latitude setText:@"N/A"];
    [_longitude setText:@"N/A"];
    [_speed setText:@"N/A"];
    [_distance setText:@"N/A"];
    [_startWorkoutButton setTitle:@"Start workout" forState:UIControlStateNormal];
    [_pauseWorkoutButton setTitle:@"" forState:UIControlStateNormal];
    [_workoutTime setText:@"N/A"];
    
    workoutPaused = NO;
    secondsPaused = 0;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startWorkout:(id)sender {
    
    NSString *buttonName = [sender titleForState:UIControlStateNormal];
    
        if ([buttonName isEqualToString:@"Start workout"]) {
            manager.delegate = self;
            manager.desiredAccuracy = kCLLocationAccuracyBest;
            [manager startUpdatingLocation];
            [sender setTitle:@"Stop workout" forState:UIControlStateNormal];
            [_pauseWorkoutButton setTitle:@"Pause workout" forState:UIControlStateNormal];
            workoutStartDate = [NSDate date];
        } else {
            [manager stopUpdatingLocation];
            [sender setTitle:@"Start workout" forState:UIControlStateNormal];
            [_latitude setText:@"N/A"];
            [_longitude setText:@"N/A"];
            [_speed setText:@"N/A"];
            [_distance setText:@"N/A"];
            [_pauseWorkoutButton setTitle:@"" forState:UIControlStateNormal];
        }
    
}

- (IBAction)pauseWorkout:(id)sender {
    
    NSString *buttonName = [sender titleForState:UIControlStateNormal];
    
    if ([buttonName isEqualToString:@"Pause workout"])
    {
        [manager stopUpdatingLocation];
        datePaused = [NSDate date];
        secondsSinceWorkoutStartWhenPaused = secondsSinceWorkoutStart;
        workoutPaused = YES;
        self.speed.text = @"Workout Paused";
        self.longitude.text = @"Workout Paused";
        self.latitude.text = @"Workout Paused";
        [sender setTitle:@"Resume workout" forState:UIControlStateNormal];
        
        //displaying the time
        
        //are we talking two-digit hours here (that's a long workout...) ?
        if (secondsSinceWorkoutStartWhenPaused/36000 >= 1) {
            NSInteger ti = (NSInteger)secondsSinceWorkoutStartWhenPaused;
            NSInteger seconds = ti % 60;
            NSInteger minutes = (ti / 60) % 60;
            NSInteger hours = (ti / 3600);
            _workoutTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
        } else if (secondsSinceWorkoutStartWhenPaused/3600 >= 1) {
            NSInteger ti = (NSInteger)secondsSinceWorkoutStartWhenPaused;
            NSInteger seconds = ti % 60;
            NSInteger minutes = (ti / 60) % 60;
            NSInteger hours = (ti / 3600);
            _workoutTime.text = [NSString stringWithFormat:@"%1ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
        } else if (secondsSinceWorkoutStartWhenPaused/600 >= 1) { //are we talking two-digit minutes?
            NSInteger ti = (NSInteger)secondsSinceWorkoutStartWhenPaused;
            NSInteger seconds = ti % 60;
            NSInteger minutes = (ti / 60) % 60;
            _workoutTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
        } else if (secondsSinceWorkoutStartWhenPaused/60 >= 1) { //are we talking one-digit minutes?
            NSInteger ti = (NSInteger)secondsSinceWorkoutStartWhenPaused;
            NSInteger seconds = ti % 60;
            NSInteger minutes = (ti / 60) % 60;
            _workoutTime.text = [NSString stringWithFormat:@"%1ld:%02ld", (long)minutes, (long)seconds];
        } else if (secondsSinceWorkoutStartWhenPaused > 0) { // are we talking seconds?
            NSInteger ti = (NSInteger)secondsSinceWorkoutStartWhenPaused;
            NSInteger seconds = ti % 60;
            _workoutTime.text = [NSString stringWithFormat:@"0:%02ld", (long)seconds];
        }
        
        
    } else {
        secondsPaused = [[NSDate date] timeIntervalSinceDate:datePaused] + secondsPaused;
        [manager startUpdatingLocation];
        [sender setTitle:@"Pause workout" forState:UIControlStateNormal];
    }

}

#pragma mark CLLocationManagerDelegate Methods



-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{

    NSLog(@"Old Location: %@", oldLocation);
    NSLog(@"New Location: %@", newLocation);
    
    CLLocation *currentLocation;
    CLLocation *pastLocation;
    
    secondsSinceWorkoutStart = [[NSDate date] timeIntervalSinceDate:[workoutStartDate dateByAddingTimeInterval:secondsPaused]];
    
    //are we talking two-digit hours here (that's a long workout...) ?
    if (secondsSinceWorkoutStart/36000 >= 1) {
        NSInteger ti = (NSInteger)secondsSinceWorkoutStart;
        NSInteger seconds = ti % 60;
        NSInteger minutes = (ti / 60) % 60;
        NSInteger hours = (ti / 3600);
        _workoutTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else if (secondsSinceWorkoutStart/3600 >= 1) {
        NSInteger ti = (NSInteger)secondsSinceWorkoutStart;
        NSInteger seconds = ti % 60;
        NSInteger minutes = (ti / 60) % 60;
        NSInteger hours = (ti / 3600);
        _workoutTime.text = [NSString stringWithFormat:@"%1ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else if (secondsSinceWorkoutStart/600 >= 1) { //are we talking two-digit minutes?
        NSInteger ti = (NSInteger)secondsSinceWorkoutStart;
        NSInteger seconds = ti % 60;
        NSInteger minutes = (ti / 60) % 60;
        _workoutTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    } else if (secondsSinceWorkoutStart/60 >= 1) { //are we talking one-digit minutes?
        NSInteger ti = (NSInteger)secondsSinceWorkoutStart;
        NSInteger seconds = ti % 60;
        NSInteger minutes = (ti / 60) % 60;
        _workoutTime.text = [NSString stringWithFormat:@"%1ld:%02ld", (long)minutes, (long)seconds];
    } else if (secondsSinceWorkoutStart > 0) { // are we talking seconds?
        NSInteger ti = (NSInteger)secondsSinceWorkoutStart;
        NSInteger seconds = ti % 60;
        _workoutTime.text = [NSString stringWithFormat:@"0:%02ld", (long)seconds];
    }
    
    if (workoutPaused == NO) {
        currentLocation = newLocation;
        pastLocation = oldLocation;
    
    if (!startingLocation)
        startingLocation = currentLocation;
    
    if (currentLocation != nil) { //location must exist to do things
        
        self.latitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        self.longitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        
        if (pastLocation != nil && [currentLocation distanceFromLocation:pastLocation] > 0) {
            
            CLLocationDistance distanceRecentlyTraveled = [currentLocation distanceFromLocation:pastLocation];
            NSString *distanceRecentlyTraveledString = [NSString stringWithFormat:@"%.8f", distanceRecentlyTraveled];
            float distanceRecentlyTraveledNumber = [distanceRecentlyTraveledString floatValue];
            float distanceRecentlyTraveledNumberMi = distanceRecentlyTraveledNumber * 0.000621371;
            if (distanceRecentlyTraveledNumberMi < .03) {
            distanceTraveledNumber = distanceRecentlyTraveledNumberMi + distanceTraveledNumber;
            distanceTraveled = [NSString stringWithFormat:@"%.2f mi", distanceTraveledNumber];
            }
            self.distance.text = distanceTraveled;
            if (currentLocation.speed > 0) {
            self.speed.text = [NSString stringWithFormat:@"%.1f mi/h", currentLocation.speed * 2.23693629];
            } else {
                self.speed.text = [NSString stringWithFormat:@"0 mi/h"];
            }
            
        } else if ([currentLocation distanceFromLocation:startingLocation] == 0) { // no movement
            
            self.distance.text = [NSString stringWithFormat:@"0 mi"];
            self.speed.text = [NSString stringWithFormat:@"0 mi/h"];
            distanceTraveledNumber = 0.00;
            
        }
    }
   
    } else {
        self.distance.text = distanceTraveled;
        self.speed.text = [NSString stringWithFormat:@"0 mi/h"];
        currentLocation = newLocation;
        pastLocation = newLocation;
        self.latitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        self.longitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        workoutPaused = NO;
        
    }
    
    
    
    
    
}




@end
