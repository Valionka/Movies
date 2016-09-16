//
//  MovieTrailerController.m
//  Movies
//
//  Created by Valentin Mihaylov on 9/15/16.
//  Copyright © 2016 codepath. All rights reserved.
//

#import "MovieTrailerController.h"


@interface MovieTrailerController ()
@property (strong, nonatomic) IBOutlet YTPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) NSString *videoId;

@end

@implementation MovieTrailerController

NSString *akey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
NSString *url = @"https://api.themoviedb.org/3/movie/%@/videos?api_key=%@";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.closeButton.layer.zPosition = 1;
    self.playerView.delegate = self;
    
    [self callMoviesApi:self.movie[@"id"]];
}

- (void) displayVideo:(NSString *) videoId {
    if(videoId) {
    NSDictionary *playerVars = @{
                                 @"playsinline" : @0,
                                 @"autoplay" : @1,
                                 };
    [self.playerView loadWithVideoId:videoId playerVars:playerVars];
    }
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback started" object:self];
    [self.playerView playVideo];
}

- (void) callMoviesApi:(NSString *) movieId{
    
   // @"https://api.themoviedb.org/3/movie/%@?/videos/api_key=%@";
    NSString *urlString = [NSString stringWithFormat:url, movieId, akey];
    
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
                                                    self.videos = responseDictionary[@"results"];
                                                    for (NSDictionary *video in self.videos) {
                                                        if([video[@"type"] isEqualToString:@"Trailer"]){
                                                            self.videoId = video[@"key"];
                                                            break;
                                                        }
                                                    }
                                                    [self displayVideo:self.videoId];
                                                    
                                                } else {
                                                    //NSLog(@"An error occurred: %@", error.description);
                                                   
                                                }
                                            }];
    
    [task resume];
}

// dismiss the modal
- (IBAction)onDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
