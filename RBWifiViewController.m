//
//  RBWifiViewController.m
//  WifiTool
//
//  Created by Rachel Brindle on 11/17/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import "RBWifiViewController.h"
#import "RBAppDelegate.h"
#import "RBShellScript.h"

@interface RBWifiViewController ()
-(void)onWifiScan:(NSArray *)results;

@end

static void scan_callback(WiFiDeviceClientRef device, CFArrayRef results, CFErrorRef error, void *token);

static void scan_callback(WiFiDeviceClientRef device, CFArrayRef results, CFErrorRef error, void *token)
{
	NSLog(@"Finished scanning! networks: %@", results);
    RBAppDelegate *ad = (RBAppDelegate*)[[UIApplication sharedApplication] delegate];
    for (UIViewController *vc in [[ad nc] viewControllers]) {
        if ([vc isKindOfClass:[RBWifiViewController class]]) {
            [((RBWifiViewController *)vc) onWifiScan:(__bridge NSArray *)results];
        }
    }
}

@implementation RBWifiViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        wifiNetworks = [[NSMutableArray alloc] init];
        manager = WiFiManagerClientCreate(kCFAllocatorDefault, 1);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    CFArrayRef networks = WiFiManagerClientCopyNetworks(manager);
    if (networks) {
        NSLog(@"%@", networks);
        CFRelease(networks);
    }
    
    CFArrayRef devices = WiFiManagerClientCopyDevices(manager);
	if (devices) {
        NSLog(@"devices (%@) has %ld devices", devices, CFArrayGetCount(devices));
        WiFiDeviceClientRef client = (WiFiDeviceClientRef)CFArrayGetValueAtIndex(devices, 0);
        WiFiDeviceClientScanAsync(client, (__bridge CFDictionaryRef)[NSDictionary dictionary], scan_callback, 0);
    }
    
	WiFiManagerClientScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    CFRelease(manager);
}

-(void)onWifiScan:(NSArray *)results
{
}

-(double)getWifiSignalStrength
{
    CFArrayRef devices = WiFiManagerClientCopyDevices(manager);
    
    WiFiDeviceClientRef client = (WiFiDeviceClientRef)CFArrayGetValueAtIndex(devices, 0);
    CFDictionaryRef data = (CFDictionaryRef)WiFiDeviceClientCopyProperty(client, CFSTR("RSSI"));
    CFNumberRef scaled = (CFNumberRef)WiFiDeviceClientCopyProperty(client, kWiFiScaledRSSIKey);
    
    CFNumberRef RSSI = (CFNumberRef)CFDictionaryGetValue(data, CFSTR("RSSI_CTL_AGR"));
    
    int raw;
    CFNumberGetValue(RSSI, kCFNumberIntType, &raw);
    
    double strength;
    CFNumberGetValue(scaled, kCFNumberFloatType, &strength);
    CFRelease(scaled);
    
    strength *= -1;
    
    // Apple uses -3.0.
    int bars = (int)ceilf(strength * -3.0f);
    bars = MAX(1, MIN(bars, 3));
    
    
    printf("WiFi signal strength: %d dBm\n\t Bars: %d\n", raw,  bars);
    
    CFRelease(data);
    CFRelease(scaled);
    CFRelease(devices);
    return strength;
}

-(void)refreshWifiNetworkList
{
    NSArray *currentNetworks = (__bridge NSArray*)WiFiManagerClientCopyNetworks(manager);
    
    NSLog(@"networks: %@", currentNetworks);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [wifiNetworks count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
