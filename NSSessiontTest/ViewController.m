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
@property (strong, nonatomic) NSMutableDictionary *countriesDict;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self parceTxt];
     [self downloadListOfCountries];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
   
    
}

#pragma mark - Refresh
//
//- (IBAction)refreshData:(UIRefreshControl *)sender {
//     NSLog(@"Wants refresh");
//   
//    
//}


#pragma mark - NSSession 


- (void)downloadListOfCountries{
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:@"https://restcountries.eu/rest/v1/all"];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
            _countries = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
//          dispatch_async(dispatch_get_main_queue(), ^{
        
              [self.tableView reloadData];

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
    NSString *countriesCode = self.countries[path.row][@"alpha2Code"] ;
    
    if ([[self.countriesDict allKeys] containsObject:countriesCode]) {
        
        ((CitiesTableViewController *)segue.destinationViewController).citiesArray = self.countriesDict[countriesCode];
    }
    else {
        return;
    }
}

-(void)parceTxt {
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"countries1" ofType:@"rtf"]; //указываем "прямой" путь к файлу
    NSError *errorReading;
    NSMutableArray *linesOfText = [NSMutableArray arrayWithArray:[[NSString stringWithContentsOfFile:filePath
                                                                                            encoding:NSUTF8StringEncoding
                                                                                               error:&errorReading]
                                                                  componentsSeparatedByString:@"\n"]]; //получаем массив строк из файла
    
    /* Удаляем строки со служебной информацией из масива */
    int i = 0;
    for (NSString *tmpStr in linesOfText) {
        NSString *firstWord = [tmpStr componentsSeparatedByString:@","].firstObject;
        if (![firstWord isEqualToString:@"Country"]) {
            i++;
        }
        else {
            break;
        }
    }
    [linesOfText removeObjectsInRange:NSMakeRange(0, i + 1)];
    
    self.countriesDict = [NSMutableDictionary new]; //словарь стран
    
    NSMutableArray *tempArray = [NSMutableArray new];
    NSString *currentCountry = @"Юлькаландия";
    
    for (NSString *str in linesOfText) {
        NSArray *cityData = [str componentsSeparatedByString:@","];
        if ([currentCountry isEqualToString:@"Юлькаландия"]) { //если текущая страна все еще "не существующая страна", то  нужно изменить текущую страну
            currentCountry = cityData.firstObject; // изменить текущую страну
            [tempArray addObject:[self parseCityDataArray:cityData]]; // и это первая запись и нужно создать 1й элемент масива
            continue; //начать новую итерацию цикла - код ниже не будет выполнен
        }
        if (![cityData.firstObject isEqualToString:currentCountry]) { //если текущая страна не такая как страна текущего горда значит это новая страна и нужно
            currentCountry = cityData.firstObject; // перезаписать текущую страну
            [self.countriesDict setObject:tempArray forKey:currentCountry.uppercaseString]; // записать масив из городов в масив стран
//            [tempArray removeAllObjects]; //очистить список городов
            tempArray = nil;
            tempArray = [NSMutableArray new];
            [tempArray addObject:[self parseCityDataArray:cityData]]; // записать текущий город в масив городов
            continue; //начать новую итерацию цикла - код ниже не будет выполнен
        }
        [tempArray addObject:[self parseCityDataArray:cityData]]; // страна не изменилась - просто дописываем текущий город в массив городо
    }
    [self.countriesDict setObject:tempArray forKey:currentCountry.uppercaseString]; //цикл завершен - дописываем в масив стран масив из город последней страны.
    
    /*на выходе получаем двумерный массив стран
     в tableView numberOfRowsInSection: передаем countriesArray.count
     
     в tableView didSelectRowAtIndexPath: инитим новый контроллер в который передаем массив из городов countriesArray[indexPath.row]
     */
    
    
}
- (NSDictionary *) parseCityDataArray:(NSArray *) array {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSArray *keysArray = @[@"Country" , @"City", @"AccentCity", @"Region", @"Population", @"Latitude", @"Longitude"];
    for (int i = 0; i < array.count; i++) {
        [dict setObject:array[i] forKey:keysArray[i]];
    }
    return dict;
}

@end
