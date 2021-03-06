//
//  ViewController.m
//  Movies
//
//  Created by Valentin Mihaylov on 9/12/16.
//  Copyright © 2016 codepath. All rights reserved.
//

#import "ViewController.h"
#import "MovieCell.h"
#import "GridMovieCellCollectionViewCell.h"
#import "MoviesDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray* movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *networkErrorView;
@property (weak, nonatomic) IBOutlet UICollectionView *gridView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewSwitch;
@property (atomic) BOOL listSelected;
@property (weak, nonatomic) IBOutlet UIImageView *errorImage;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, atomic) NSURLSessionDataTask *task;

@end

@implementation ViewController

//NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
NSString *npUrl = @"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed";
NSString *trUrl = @"https://api.themoviedb.org/3/movie/top_rated?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed";
NSString *searchUrl = @"https://api.themoviedb.org/3/search/movie?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&query=";

- (IBAction)onViewSwitch:(id)sender {
    if(self.viewSwitch.selectedSegmentIndex == 0) {
        self.listSelected = YES;
        self.gridView.hidden = YES;
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        [self.tableView insertSubview:self.refreshControl atIndex:0];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    } else {
        self.listSelected = NO;
        self.tableView.hidden = YES;
        self.gridView.hidden = NO;
        [self.gridView reloadData];
        [self.gridView insertSubview:self.refreshControl atIndex:0];
        self.gridView.dataSource = self;
        self.gridView.delegate = self;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.navigationItem.titleView = self.searchBar;
    self.searchBar.delegate = self;
    
    // display list view when loaded
    self.listSelected = YES;
    self.gridView.hidden = YES;
    
    // refresher
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];

    // set up network error msg
    self.networkErrorView.layer.zPosition = 1;
    self.networkErrorView.hidden = YES;
    
    // network error image
    self.errorImage.image = [UIImage imageNamed:@"error.png"];
    
    // set the sources
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // call the endpoints depending on the tab
    if([self.endpoint isEqualToString:@"now_playing"]){
        [self callMoviesApi:npUrl];
       } else {
        [self callMoviesApi:trUrl];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // NSLog(@"Text changed: %@",searchText);
     searchText = [searchText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if(searchText.length > 1){
        NSString *urlString = [searchUrl stringByAppendingString:searchText];
        [self callMoviesApi:urlString];
    } else {
        if([self.endpoint isEqualToString:@"now_playing"]){
            [self callMoviesApi:npUrl];
        } else {
            [self callMoviesApi:trUrl];
        }
    }
}

- (void)onRefresh {
    if([self.endpoint isEqualToString:@"now_playing"]){
        [self callMoviesApi:npUrl];
    } else {
        [self callMoviesApi:trUrl];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton =YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if([self.endpoint isEqualToString:@"now_playing"]){
        [self callMoviesApi:npUrl];
    } else {
        [self callMoviesApi:trUrl];
    }
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    [self.searchBar resignFirstResponder];
}

- (void) callMoviesApi:(NSString *) urlString {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    
     self.task = [session dataTaskWithRequest:request
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
                                                    if(self.listSelected){
                                                        [self.tableView reloadData];
                                                    } else {
                                                        [self.gridView reloadData];
                                                    }
                                                    self.networkErrorView.hidden = YES;
                                                } else {
                                                    //NSLog(@"An error occurred: %@", error.description);
                                                    self.networkErrorView.hidden = NO;
                                                    
                                                }
                                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                            }];
    
    
    [self.refreshControl endRefreshing];
    [self.task resume];

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
   
    [cell.movieImage setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"defaultMovie.png"]];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.movies.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    GridMovieCellCollectionViewCell *cell = [self.gridView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.movies[indexPath.row];
    NSString *url = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w154%@", movie[@"poster_path"]];
    
    [cell.movieImageGridView setImageWithURL:[NSURL URLWithString:url]];
    //[cell.movieImageGridView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"gridDefaultMovie.png"]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath;
    if(self.listSelected){
         indexPath = [self.tableView indexPathForCell:sender];
    } else {
         indexPath = [self.gridView indexPathForCell:sender];
    }
    MoviesDetailViewController *vc = segue.destinationViewController;
    
    vc.movie = self.movies[indexPath.row];
}

@end
