//
//  ViewController.m
//  Movies
//
//  Created by Valentin Mihaylov on 9/12/16.
//  Copyright © 2016 codepath. All rights reserved.
//

#import "ViewController.h"
#import "MovieCell.h"
#import "MoviesDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ViewController

NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
NSString *npUrl = @"https://api.themoviedb.org/3/movie/now_playing?api_key=";
NSString *trUrl = @"https://api.themoviedb.org/3/movie/top_rated?api_key=";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    if([self.endpoint isEqualToString:@"now_playing"]){
        [self callMoviesApi:npUrl];
       } else {
        [self callMoviesApi:trUrl];
    }
}

- (void)onRefresh {
    if([self.endpoint isEqualToString:@"now_playing"]){
        [self callMoviesApi:npUrl];
    } else {
        [self callMoviesApi:trUrl];
    }
}


- (void) callMoviesApi:(NSString *) apiUrl {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlString =
    [apiUrl stringByAppendingString:apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    // NSLog(@"Response: %@", responseDictionary);
                                                    self.movies = responseDictionary[@"results"];
                                                    [self.tableView reloadData];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                            }];
    
    
    [self.refreshControl endRefreshing];
    [task resume];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.movies[indexPath.row];
    
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    NSString *url = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w154%@", movie[@"poster_path"]];
   
    
    [cell.movieImage setImageWithURL:[NSURL URLWithString:url]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    MoviesDetailViewController *vc = segue.destinationViewController;
    
    vc.movie = self.movies[indexPath.row];
}

@end
