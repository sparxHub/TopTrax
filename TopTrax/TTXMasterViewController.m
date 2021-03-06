//
//  TTXMasterViewController.m
//  TopTrax
//
//  Created by Spark on 3/12/15.
//  Copyright (c) 2015 Spark. All rights reserved.
//

#import "TTXMasterViewController.h"
#import "MasterNavigationController.h"
#import "TTXArtistFlowLayout.h"

// View Model
#import "TTXMasterViewModel.h"
#import "TTXArtist.h"

// View Controllers
#include "TTXArtistViewController.h"

#include "TTXArtistUITableViewCell.h"

typedef NS_ENUM(NSUInteger, NSCountry) {
    NSCountrySpain = 0,
    NSCountryItaly,
    NSCountryJapan,
    NSCountrySweden,
    NSCountryGermany
};

@interface TTXMasterViewController () 

@property(nonatomic) NSCountry currentCountry;

@end

@implementation TTXMasterViewController

#pragma mark - UIViewController Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[((MasterNavigationController *)self.navigationController) pulldownMenu] setDelegate:self];
    
    @weakify(self);
    [self.viewModel.updatedContentSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewModel.active = YES;
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TTXArtistFlowLayout *flowLayout = [[TTXArtistFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    TTXArtistViewController *viewController = [[TTXArtistViewController alloc] initWithCollectionViewLayout:flowLayout];
    viewController.viewModel = [self.viewModel artistViewModelForIndexPath:indexPath];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.viewModel.artists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell2";
    TTXArtistUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TTXArtistUITableViewCell" owner:self options:nil] lastObject];
    }

    TTXArtist *artist = self.viewModel.artists[indexPath.row];
    [cell setArtistModel:artist];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    // Always return YES.
    return NO;
}

// This function is where all the magic happens
// Credit to: Yari @bitwaker
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //1. Setup the CATransform3D structure
    CATransform3D rotation;
    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
    rotation.m34 = 1.0/ -600;
    
    
    //2. Define the initial state (Before the animation)
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0;
    
    cell.layer.transform = rotation;
    cell.layer.anchorPoint = CGPointMake(0, 0.5);
    
    //!!!FIX for issue #1 Cell position wrong------------
    if(cell.layer.position.x != 0){
        cell.layer.position = CGPointMake(0, cell.layer.position.y);
    }
    
    //4. Define the final state (After the animation) and commit the animation
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.8];
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}

#pragma mark - Navigation

- (IBAction)openCloseCountriesMenu:(id)sender {
    [((MasterNavigationController *)self.navigationController).pulldownMenu animateDropDown];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"showArtist"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        
//        TTXArtistViewController *viewController = segue.destinationViewController;
//        viewController.viewModel = [self.viewModel artistViewModelForIndexPath:indexPath];
//    }
//}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return (self.editing == NO);
}

#pragma mark - PulldownMenu

-(void)menuItemSelected:(NSIndexPath *)indexPath {
    //NSLog(@"Menu selected:%d",indexPath.item);
    
    self.currentCountry = (NSCountry)indexPath.item;
    
    switch (self.currentCountry) {
        case NSCountrySpain:
            [self.viewModel updateTopArtistsWithCountry:@"spain"];
            break;
        case NSCountryItaly:
            [self.viewModel updateTopArtistsWithCountry:@"italy"];
            break;
        case NSCountryJapan:
            [self.viewModel updateTopArtistsWithCountry:@"japan"];
            break;
        case NSCountrySweden:
            [self.viewModel updateTopArtistsWithCountry:@"sweden"];
            break;
        case NSCountryGermany:
            [self.viewModel updateTopArtistsWithCountry:@"germany"];
            break;
    }
    
    
    [((MasterNavigationController *)self.navigationController).pulldownMenu animateDropDown];
}

-(void)pullDownAnimated:(BOOL)open {
    
}

#pragma mark - Private Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TTXArtist *artist = self.viewModel.artists[indexPath.row];
    
//    UIImageView *artistImageView = (UIImageView *)[cell viewWithTag:100];
//    artistImageView.image = [UIImage imageWithData:artist.imageData];
    
    UILabel *artistNameLabel = (UILabel *)[cell viewWithTag:101];
    artistNameLabel.text = artist.name;
    
    UILabel *artistDetailLabel = (UILabel *)[cell viewWithTag:102];
    artistDetailLabel.text = [NSString stringWithFormat:@"(%@ Listeners)", artist.listeners];

//    cell.textLabel.text = artist.name;
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@ Listeners)", artist.listeners];
}

@end
