//
//  DetailTableViewController.m
//  KCAddressBook
//
//  Created by Jason Kurczak on 2014-12-30.
//  Copyright (c) 2014 Jason Kurczak. All rights reserved.
//

#import "DetailTableViewController.h"

@interface DetailTableViewController ()

@end

@implementation DetailTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setContactDictionary:(NSDictionary *)newContactDictionary
{
    if (_contactDictionary != newContactDictionary)
    {
        _contactDictionary = newContactDictionary;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if ( self.contactDictionary )
    {
        // to ensure that the table works correctly when asked for an abritrary row
        // we need to put (and ideally sort) the contact info into an array
        // because NSDictionaries are not ordered
        
        // TODO
        // this should order the info based on type (name, then phone, etc)
        
        // there are two subvalues in the dictionary, user and seed
        self.availableContactInfo = [ [ self.contactDictionary objectForKey:@"user" ] allKeys ];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // TODO
    // using only one section for now, could make prettier by separating sections based
    // on data type
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ( self.availableContactInfo )
    {
        // we want one row per info item for this contact
        // each row will contain an intelligent concatenation of
        // all of the sub-info in case of dictionary rather than string
        return self.availableContactInfo.count;
    }
    else
    {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    if ( self.availableContactInfo )
    {
        // we assume that the keys are all strings
        // if this is not true, we are using an unexpected data format
        NSObject *key = [ self.availableContactInfo objectAtIndex:indexPath.row ];
        if ( [ key isKindOfClass:[ NSString class ] ] )
        {
            NSString *keyString = [ self.availableContactInfo objectAtIndex:indexPath.row ];
            NSString *keyPath = [ NSString stringWithFormat:@"user.%@", keyString ];
            NSObject *currentValue = [ self.contactDictionary valueForKeyPath:keyPath ];
            
            if ( [ currentValue isKindOfClass:[ NSDictionary class ] ] )
            {
                // current info is a dictionary, need to concatenate all values into one
                
                // TODO
                // this should be done intelligently based on the key's value (address, name, etc)
                // but even better would be putting this info into a custom Contact class ahead of time
                
                NSDictionary *valueDictionary = (NSDictionary *)currentValue;
                
                NSMutableString *valueString = [ NSMutableString stringWithString:@"" ];
                
                for ( NSObject *subValue in [ valueDictionary allValues ] )
                {
                    // add each subvalue as a string concatenated to the mutable string
                    
                    if ( [ subValue isKindOfClass:[ NSString class ] ] )
                    {
                        // add the string directly
                        [ valueString appendString:
                         [ NSString stringWithFormat:@" %@", (NSString *)subValue ] ];
                    }
                    else
                    {
                        // Not a string - unexpected
                        // could be a nested dictionary?
                        // TODO
                        // This could be turned into a recursive function that deep-dives into
                        // nested dictionaries
                        // but that should be unnecessary with a well-defined contact data format
                        // and if this info will be pre-sorted into a custom Contact object
                        NSLog( @"Error - subvalue of contact info dictionary was not string" );
                    }
                }
                
                cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", keyString, valueString ];
                
            }
            else if ( [ currentValue isKindOfClass:[ NSString class ] ] )
            {
                // this is just a string, we can display the value directly
                NSString *valueString = (NSString *)currentValue;
                
                cell.textLabel.text = [ NSString stringWithFormat:@"%@: %@", keyString, valueString ];
            }
            else
            {
                // unknown type of object, expect either string or dictionary of strings
                // leave as unknown for now
                NSLog( @"Error - displaying contact info failed to understand type of value" );
                
                cell.textLabel.text = @"Unable to display this type of contact info";
            }
        }
        else
        {
            NSLog( @"Error - key %@ is not a string, unexpected data format", [ key description ] );
            cell.textLabel.text = @"Unable to display this type of contact info";
        }
    }
    else
    {
        cell.textLabel.text = @"Data unavailable";
    }
    
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // this is not necessary
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
