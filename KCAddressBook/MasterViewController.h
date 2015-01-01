//
//  MasterViewController.h
//  KCAddressBook
//
//  Created by Jason Kurczak on 2014-12-30.
//  Copyright (c) 2014 Jason Kurczak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailTableViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailTableViewController *detailTableViewController;
@property (strong, atomic) NSArray *contactsArray;

@end

