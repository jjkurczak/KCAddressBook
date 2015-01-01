//
//  MasterViewController.m
//  KCAddressBook
//
//  Created by Jason Kurczak on 2014-12-30.
//  Copyright (c) 2014 Jason Kurczak. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailTableViewController.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    _contactsArray = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // TODO
    // Add an EDIT button for when we actually have a local store of values
    // this requires
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    // TODO
    // Add an ADD button for when we actually have a local store of values
    // this would bring up a sheet that allows the user to input the contact data
    
    /*
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
     */
    
    self.detailTableViewController = (DetailTableViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // using RandomUser.me
    // forcing version 0.4.1 (current) to prevent issues if API changes in future
    NSURL *contactGeneratorUrl = [ NSURL URLWithString:@"http://api.randomuser.me/0.4.1/?results=100" ];
    
    [ self getContactsJSONDataFromUrl:contactGeneratorUrl ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *contactToDisplay = self.contactsArray[indexPath.row];
        DetailTableViewController *controller = (DetailTableViewController *)[[segue destinationViewController] topViewController];
        [controller setContactDictionary:contactToDisplay];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( self.contactsArray != nil )
    {
        NSLog( @"Returning %ld rows in section %ld", self.contactsArray.count, section );
        return self.contactsArray.count;
    }
    else
    {
        NSLog( @"Returning 0 rows in section %ld, no contacts array", section );
        return 0;
    }
     //return self.contactsDictionary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog( @"Asking for cell at indexpath %ld, %ld", indexPath.section, indexPath.row );
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // TODO
    // These should either be extracted in another method to build a more efficient data type
    // like an array of structs (depending on how slow NSDicionaries are)
    
    NSDictionary *contact = [ self.contactsArray objectAtIndex:indexPath.row ];
    NSString *firstName = [ contact valueForKeyPath:@"user.name.first" ];
    NSString *lastName = [ contact valueForKeyPath:@"user.name.last" ];
    NSString *title = [ contact valueForKeyPath:@"user.name.title" ];
    
    // TODO
    // There should be more code here to handle all the different possible
    // combinations of possible names and titles
    // for now assume 1 title, 1 first, 1 last name
    
    cell.textLabel.text = [ NSString stringWithFormat:@"%@ %@ %@", title, firstName, lastName ];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    // TODO
    // this is set to "no" because we don't currently have editing working yet
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO
    // this needs to handle edits, but since we do not have a local store to edit
    // editing is turned off for now
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // TODO
        // insert logic to remove actual data from (not yet existant) local store of contacts
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - Grabbing contacts from web

- (void)getContactsJSONDataFromUrl:(NSURL *)sourceURL;
{
    NSURLRequest *contactRequest = [ NSURLRequest requestWithURL:sourceURL ];
    
    [ NSURLConnection sendAsynchronousRequest:contactRequest
                                        queue:[ NSOperationQueue mainQueue ]
                            completionHandler:^(NSURLResponse *response,
                                                NSData *data,
                                                NSError *connectionError)
     {
         // completion handler
         
         if ( connectionError == nil )
         {
             // check response
             // should be an http response
             
             if ( [ response isKindOfClass:[ NSHTTPURLResponse class ] ] )
             {
                 // this is the expected type of response for HTTP request
                 // safely cast to correct type
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                 
                 // check response value
                 if ( httpResponse.statusCode == 200 )
                 {
                     // successful response! we can save the data
                     NSLog( @"Received JSON data from contacts generator!" );
                     
                     NSArray *contacts = [ self parseRUContactsFromJSONData:data ];
                     
                     if ( contacts != nil )
                     {
                         NSLog( @"Have contacts array of size %ld", contacts.count );
                         
                         // TODO
                         // now we have an unsorted array, but it should be sorted.
                         // Probably alphabetical order based on either first or last name
                         // this should be done with user's local region/language prefs
                         
                         // TODO
                         // if we want search, we should configure the table as uisearchbardelegate
                         // and add logic to handle searching the (well-organized) array for
                         // any of the info contained in the custom Contact class we should
                         // probably create
                         self.contactsArray = contacts;
                         
                         // NOTE - is this safe to run here?
                         // is this completion block running on the main UI thread?
                         [ self.tableView reloadData ];
                     }
                     else
                     {
                         NSLog( @"Could not parse JSON data received from %@",
                               response.URL.absoluteString );
                     }
                     
                 }
                 else
                 {
                     // successful connection but unsuccesful http resquest
                     
                     NSLog( @"Error - Connected to %@ but received response status: %ld - %@",
                           response.URL.absoluteString,
                           httpResponse.statusCode,
                           [ NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode ] );
                 }
             }
             else
             {
                 // unexpected type of response for HTTP request
                 
                 NSLog( @"Error - in connectiong to %@, received non-http response",
                       response.URL.absoluteString );
             }
         }
         else
         {
             // connection error
             
             NSLog( @"Error - connection problem %ld: %@",
                   connectionError.code,
                   connectionError.localizedDescription );
         }
     }];
}

- (NSArray *)parseRUContactsFromJSONData:(NSData *)theJSONData
{
    // we are given JSON data containing contacts in RandomUser.me format
    // try to parse the json data into an Apple Foundation (Cocoa-compatible) object
    NSError *parseError = nil;
    id contactsObject = [NSJSONSerialization JSONObjectWithData:theJSONData options:kNilOptions error:&parseError];
    
    if ( [ contactsObject isKindOfClass:[ NSDictionary class ] ] )
    {
        // treat the incoming data as a dictionary
        NSDictionary *receivedContactsDictionary = (NSDictionary *)contactsObject;
        
        NSLog( @"Received JSON data back" );
        
        NSArray *contactsArray = [ receivedContactsDictionary objectForKey:@"results" ];
        
        return [ NSArray arrayWithArray:contactsArray ];
    }
    else
    {
        // unexpected result, should be dictionary
        NSLog( @"Error - Contacts JSON in NSData format is not a dictionary, unexpected data format" );
        
        return nil;
    }
}

@end
