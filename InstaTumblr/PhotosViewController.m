//
//  ViewController.m
//  InstaTumblr
//
//  Created by Monika Gupta on 9/14/16.
//  Copyright (c) 2016 codepath. All rights reserved.
//

#import "PhotosViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PhotoViewCell.h"
#import "PhotoDetailsViewController.h"

@interface PhotosViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *posts;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation PhotosViewController

-(void) getPostsCall {
    NSString *clientId = @"Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV";
    NSString *urlString =
    [@"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=" stringByAppendingString:clientId];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * data,
                                                                NSURLResponse * response,
                                                                NSError *  error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    //NSLog(@"Response: %@", responseDictionary);
                                                    self.posts = responseDictionary[@"response"][@"posts"];
                                                    [self.tableView reloadData];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(getPostsCall) forControlEvents:UIControlEventValueChanged];
    [self getPostsCall];
    self.tableView.rowHeight = 320;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.posts.count;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [headerView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
    
    UIImageView *profileView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    [profileView setClipsToBounds:YES];
    profileView.layer.cornerRadius = 15;
    profileView.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:0.8].CGColor;
    profileView.layer.borderWidth = 1;
    
    NSURL* imageURL = [[NSURL alloc] initWithString:@"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"];

    // Use the section number to get the right URL
    [profileView setImageWithURL:imageURL];
    [headerView addSubview:profileView];

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    //[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss 'GMT'";
    NSDate *publishedDate = [dateFormatter dateFromString:self.posts[section][@"date"]];
    dateFormatter.dateFormat = @"MMM dd, yyyy";
    
    UILabel *publishedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 300, 30)];
    
    publishedDateLabel.text = [dateFormatter stringFromDate:publishedDate];
    publishedDateLabel.textColor = [UIColor blackColor];
    publishedDateLabel.font = [UIFont fontWithName:@"" size:10];
    [headerView addSubview:publishedDateLabel];
    
    
    // Add a UILabel for the username here
    
    return headerView;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //PhotoViewCell *cell =
    PhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoViewCell"];
    NSDictionary *post = self.posts[indexPath.section];
    
    cell.photoView.image = nil;
    //cell.image.image
    NSArray *photos = post[@"photos"];
    NSString *oriSizePhoto = photos[0][@"original_size"][@"url"];
    NSURL* imageURL = [[NSURL alloc] initWithString:oriSizePhoto];
    [cell.photoView setImageWithURL:imageURL];
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    PhotoDetailsViewController *photoDetailsViewController = segue.destinationViewController;
    photoDetailsViewController.photoUrl = self.posts[indexPath.section][@"photos"][0][@"original_size"][@"url"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
