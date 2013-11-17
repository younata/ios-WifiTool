//
//  RBWifiViewController.h
//  WifiTool
//
//  Created by Rachel Brindle on 11/17/13.
//  Copyright (c) 2013 Rachel Brindle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileWiFi.h"

@interface RBWifiViewController : UITableViewController
{
    NSMutableArray *wifiNetworks;
    WiFiManagerRef manager;
}

@end
