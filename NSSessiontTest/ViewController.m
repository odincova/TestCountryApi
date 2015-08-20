//
//  ViewController.m
//  NSSessiontTest
//
//  Created by Juliya on 19.08.15.
//  Copyright (c) 2015 Juliya Odincova. All rights reserved.
//

#import "ViewController.h"
#import "CitiesTableViewController.h"

@interface ViewController ()
//<NSURLSessionDelegate, NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSArray *countries;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
  //  [self downloadListOfCountries];
    
}

#pragma mark - Refresh

- (IBAction)refreshData:(UIRefreshControl *)sender {
     NSLog(@"Wants refresh");
    
    [self downloadListOfCountries:^(id result) {
        [self.refreshControl endRefreshing];
        if ([result isKindOfClass:[NSError class]]) {
            //
        } else if ([result isKindOfClass:[NSData class]]) {
            NSError *error;
            self.countries = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
        }
        
    }];
    
    
}


#pragma mark - NSSession 


- (void)downloadListOfCountries:(void(^)(id result))completion{
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:@"https://restcountries.eu/rest/v1/all"];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
            _countries = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", _countries);
//          dispatch_async(dispatch_get_main_queue(), ^{
//              
//              [self.tableView reloadData];
//
//          });
//            
      
        
    }] resume];
}

    
#pragma mark - UITableViewDataSource<NSObject>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.countries.count;
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        static NSString *identifier = @"Cell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        id countryObject = self.countries[indexPath.row];
        
        cell.textLabel.text = countryObject[@"name"];
        cell.detailTextLabel.text = [countryObject[@"population"] stringValue];
        
    }
    
    return cell;
    
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    NSString *city = [self.countries objectAtIndex:path.row];
    
    ((CitiesTableViewController *)segue.destinationViewController).city = city;
}


@end
