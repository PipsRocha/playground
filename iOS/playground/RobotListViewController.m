//
//  RobotListViewController.m
//  playground
//
//  Created by Kevin Liang on 11/17/14.
//  Copyright (c) 2014 Wonder Workshop. All rights reserved.
//

#import "RobotListViewController.h"
#import "RobotControlPanelViewController.h"
#import "RobotControlViewController.h"
#import "RobotListTableViewCell.h"

@interface RobotListViewController ()

@property NSMutableArray *robots;

@end


@implementation RobotListViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.controlPanelViewController = (RobotControlPanelViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.robots = [NSMutableArray new];
  
    // hack to get scene navigation to work on phones.
    // for some reason cell-selection no longer triggers the segue back.
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.buttonBackToControls.hidden = true;
    }
  
    // load custom nib
    [self.tableView registerNib:[UINib nibWithNibName:@"RobotListTableViewCell" bundle:nil] forCellReuseIdentifier:@"RobotListTableViewCell"];
    
    // setup robot manager
    self.manager = [WWRobotManager manager];
    NSAssert(self.manager, @"unable to instantiate robot manager");
  [self.manager addManagerObserver:self];
  [self.manager startScanningForRobots:2.0f];
    
    self.tableView.rowHeight = 130;
    UIColor *start = [UIColor colorWithRed:58/255.0 green:108/255.0 blue:183/255.0 alpha:0.15];
    UIColor *stop = [UIColor colorWithRed:58/255.0 green:108/255.0 blue:183/255.0 alpha:0.45];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [self.view bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)start.CGColor, (id)stop.CGColor, nil];
    [self.tableView.layer insertSublayer:gradient atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // oxe 201702: segue identifier is always null.
    // if ([[segue identifier] isEqualToString:@"showDetail"]) {
      // oxe 201702: this line seems orphaned. indexPath is unused.
      // NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      RobotControlPanelViewController *controller = (RobotControlPanelViewController *)[segue destinationViewController];
      controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
      controller.navigationItem.leftItemsSupplementBackButton = YES;
    // }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.robots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RobotListTableViewCell *cell = (RobotListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RobotListTableViewCell" forIndexPath:indexPath];
    
    // status
    WWRobot *robot = (WWRobot *)self.robots[indexPath.row];
    if (robot.isConnected) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:50/255.0 green:200/255.0 blue:50/255.0 alpha:0.6];
    }
    else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.6];
    }
    
    // robot info
    NSMutableString *detail = [NSMutableString stringWithCapacity:200];
    [detail appendFormat:@"uuId: %@\n", robot.uuId];
    [detail appendFormat:@"Firmware %@\n", robot.firmwareVersion];
    [detail appendFormat:@"Serial: %@\n", robot.serialNumber];
    [detail appendFormat:@"RSSI %d dB\n", robot.signalStrength.intValue];
    [detail appendFormat:@"Personality color: %d\n", robot.personalityColorIndex];
    cell.infoLabel.text = detail;
    
    // robot name
    cell.nameLabel.text = robot.name;
    
    // image
    switch (robot.robotType) {
        case WW_ROBOT_DOT:
            cell.robotImageView.image = [UIImage imageNamed:@"dot.png"];
            break;
        case WW_ROBOT_DASH:
            cell.robotImageView.image = [UIImage imageNamed:@"dash.png"];
            
        default:
            break;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WWRobot *robot = self.robots[indexPath.row];
    if (robot.isConnected) {
        [self.manager disconnectFromRobot:robot];
    }
    else {
        [self.manager connectToRobot:robot];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - RobotManagerDelegate

- (void) manager:(WWRobotManager *)manager didDiscoverRobot:(WWRobot *)robot {
    if (![self.robots containsObject:robot]) {
        // found new robots, refresh list
        [self.robots addObject:robot];
        [self.tableView reloadData];
    }
}

- (void) manager:(WWRobotManager *)manager didUpdateDiscoveredRobots:(WWRobot *)robot {
    // existing robots have new data, refresh
    [self.tableView reloadData];
}

- (void) manager:(WWRobotManager *)manager didLoseRobot:(WWRobot *)robot {
    // lost connectivity with existing robot, refresh list
    [self.robots removeObject:robot];
    [self.tableView reloadData];
}

- (void) manager:(WWRobotManager *)manager didConnectRobot:(WWRobot *)robot {
    // connected with robot, refresh
    [self.tableView reloadData];
    [self.controlPanelViewController.activeControlVC refreshConnectedRobots];
}

- (void) manager:(WWRobotManager *)manager didFailToConnectRobot:(WWRobot *)robot error:(WWError *)error {
    NSLog(@"failed to connect to robot: %@, with error: %@", robot.name, error);
    [NSNumber numberWithUnsignedInteger:WW_SENSOR_BUTTON_MAIN];
}

- (void) manager:(WWRobotManager *)manager didDisconnectRobot:(WWRobot *)robot {
    // disconnected with robot, refresh
    [self.tableView reloadData];
}

@end
