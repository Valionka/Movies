//
//  MoviesDetailViewController.m
//  Movies
//
//  Created by Valentin Mihaylov on 9/12/16.
//  Copyright © 2016 codepath. All rights reserved.
//

#import "MoviesDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

@interface MoviesDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UILabel *movieDate;
@property (weak, nonatomic) IBOutlet UILabel *movieRating;
@property (weak, nonatomic) IBOutlet UILabel *movieRunTime;
@property (weak, nonatomic) IBOutlet UILabel *movieDescription;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingIcon;
@property (weak, nonatomic) IBOutlet UIImageView *durationIcon;
@property (weak, nonatomic) IBOutlet UIImageView *trailerImage;

@end

@implementation MoviesDetailViewController

NSString *key = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *url = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w342%@", self.movie[@"poster_path"]];
    
    [self.bgImage setImageWithURL:[NSURL URLWithString:url]];

    self.movieTitle.text = self.movie[@"title"];
    self.movieDescription.text = self.movie[@"overview"];
    [self.movieDescription sizeToFit];
    

    self.ratingIcon.image = [UIImage imageNamed:@"crown.png"];
    self.durationIcon.image = [UIImage imageNamed:@"clock.png"];
    self.trailerImage.image = [UIImage imageNamed:@"trailer.png"];
    // fix the floating point number precision
    float rating = [self.movie[@"vote_average"] floatValue];
    self.movieRating.text = [NSString stringWithFormat:@"%.02f%@", rating, @"%"];
    
    NSString *apiUrl = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", self.movie[@"id"], key];

    // get the movie run time
    [self callMoviesApi:apiUrl];
    
    // set the release date
    NSString *dateString = self.movie[@"release_date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    
    dateFromString = [dateFormatter dateFromString:dateString];
   
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    self.movieDate.text = [dateFormatter stringFromDate:[NSDate date]];
    
    CGRect frame = self.detailsView.frame;
    frame.size.height = self.movieDescription.frame.size.height + self.movieDescription.frame.origin.y + 10;
    self.detailsView.frame = frame;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 60 + self.detailsView.frame.origin.y + self.detailsView.frame.size.height);
}


- (void) callMoviesApi:(NSString *) apiUrl {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSURL *url = [NSURL URLWithString:apiUrl];
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
                                                     //NSLog(@"Response: %@", responseDictionary);
                                                     int runtime = [responseDictionary[@"runtime"] intValue];
                                                     int hours = runtime / 60;
                                                     int minutes = runtime % 60;
                                                     self.movieRunTime.text = [NSString stringWithFormat:@"%d %@ %d %@", hours, @"hr", minutes, @"mins"];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [task resume];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath;
    MoviesDetailViewController *vc = segue.destinationViewController;
    
    vc.movie = self.movie;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
