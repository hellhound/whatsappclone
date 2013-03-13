#import "Services/Controllers/TChat/TLRosterController.h"
#import "TLTChatViewController.h"
#import "TLRosterViewController.h"

NSString *const kTLRosterViewCellId = @"TLRosterViewCell";

@interface TLRosterViewController()

@property (nonatomic, strong) TLRosterController *service;
@end

@implementation TLRosterViewController

#pragma mark -
#pragma mark UITableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    if ((self = [super initWithStyle:style]) != nil) {
        self.title = @"Friends";
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

#pragma mark -
#pragma mark <UITableViewDataSource>

- (NSInteger)   tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section
{
    return [self.service numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:kTLRosterViewCellId];

    if (cell == nil)
        cell = [[UITableViewCell alloc]
            initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:kTLRosterViewCellId];
    cell.textLabel.text = [self.service buddyDisplayNameForIndex:indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark <UITableViewDelegate>

- (void)        tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *accountName =
        [self.service buddyAccountNameForIndex:indexPath.row];
    NSString *displayName =
        [self.service buddyDisplayNameForIndex:indexPath.row];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController
        pushViewController:[[TLTChatViewController alloc]
        initWithBuddyAccountName:accountName displayName:displayName
        photo:nil]
        animated:YES];
}

#pragma mark -
#pragma mark <TLRosterViewController>

- (void)controllerDidPopulateRoster:(TLRosterController *)controller
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark TLRosterViewController

@synthesize service;

- (TLRosterController *)service
{
    if (service == nil)
        service = [[TLRosterController alloc] initWithDelegate:self];
    return service;
}
@end
