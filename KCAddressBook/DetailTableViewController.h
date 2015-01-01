//
//  DetailTableViewController.h
//  KCAddressBook
//
//  Created by Jason Kurczak on 2014-12-30.
//  Copyright (c) 2014 Jason Kurczak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTableViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *contactDictionary;
@property (strong, nonatomic) NSArray *availableContactInfo;


@end
