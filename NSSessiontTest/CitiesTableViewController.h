//
//  CitiesTableViewController.h
//  NSSessiontTest
//
//  Created by Juliya on 20.08.15.
//  Copyright (c) 2015 Juliya Odincova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CitiesTableViewController : UITableViewController

@property (nonatomic, copy) NSString *city;
@property (strong, nonatomic) NSString *countryKey;
@property (strong, nonatomic) NSMutableArray *citiesArray;

@end
