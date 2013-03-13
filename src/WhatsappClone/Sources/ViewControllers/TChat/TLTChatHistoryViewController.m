#import "Views/TLTChatHistoryViewCell.h"
#import "Services/Controllers/TChat/TLTChatHistoryController.h"
#import "TLRosterViewController.h"
#import "TLTChatViewController.h"
#import "TLTChatHistoryViewController.h"

NSString *const kTLHistoryViewCellId = @"TLHistoryViewCellId";

@interface TLTChatHistoryViewController ()

@property (nonatomic, strong) TLTChatHistoryController *service;

- (void)newChatWindow;
@end

@implementation TLTChatHistoryViewController

#pragma mark -
#pragma mark UIViewController

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navItem = super.navigationItem;
    if (!navItem.leftBarButtonItem) {
        UIButton *editButton =
            [[UIButton alloc] initWithFrame:CGRectMake(.0, .0, 25., 25.)];

        [editButton setImage:[UIImage imageNamed:@"edit"]
            forState:UIControlStateNormal];
        [editButton addTarget:nil action:nil
             forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem *editButtonItem =
            [[UIBarButtonItem alloc] initWithCustomView:editButton];

        navItem.leftBarButtonItem = editButtonItem;
    }
    if (!navItem.rightBarButtonItem) {
        UIButton *newChatButton =
            [[UIButton alloc] initWithFrame:CGRectMake(.0, .0, 25., 25.)];

        [newChatButton setImage:[UIImage imageNamed:@"newChat"]
            forState:UIControlStateNormal];
         [newChatButton addTarget:self action:@selector(newChatWindow)
             forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem *newChatButtonItem =
            [[UIBarButtonItem alloc] initWithCustomView:newChatButton];

        navItem.rightBarButtonItem = newChatButtonItem;
    }
    return navItem;
}

#pragma mark -
#pragma mark UITableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    if ((self = [super initWithStyle:style]) != nil) {
        self.title = @"TCHAT";
        [self.service populateBuddies];
    }
    return self;
}

#pragma mark -
#pragma mark <UITableViewDataSource>

- (NSInteger)   tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section
{
    return [self.service buddiesCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLTChatHistoryViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:kTLHistoryViewCellId];
    if (cell == nil)
        cell = [[TLTChatHistoryViewCell alloc]
            initWithStyle:UITableViewCellStyleSubtitle
          reuseIdentifier:kTLHistoryViewCellId];

    NSDictionary *buddy = [self.service buddyAtIndex:indexPath.row];

    cell.textLabel.text = [buddy objectForKey:@"displayName"];
    cell.detailTextLabel.text = [buddy objectForKey:@"lastMessage"];
    NSData *photoData = [buddy objectForKey:@"photo"];
    if (photoData != nil) {
        cell.imageView.image = [[UIImage alloc] initWithData:photoData];
    }
    cell.lastDate = [buddy objectForKey:@"lastDate"];
    cell.unreadMessages = [buddy objectForKey:@"unreadMessages"];
    return cell;
}

#pragma mark -
#pragma mark <UITableViewDelegate>

- (void)        tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *buddy = [self.service buddyAtIndex:indexPath.row];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:[[TLTChatViewController alloc]
        initWithBuddyAccountName:[buddy objectForKey:@"accountName"]
        displayName:[buddy objectForKey:@"displayName"]
        photo:[buddy objectForKey:@"photo"]]
        animated:YES];
}

- (CGFloat)     tableView:(UITableView *)tableView 
  heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TLTChatHistoryViewCell getCellHeight];
}

#pragma mark -
#pragma mark <TLTChatHistoryControllerDelegate>

- (void)updateData
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark TLTChatHistoryViewController

@synthesize service;

- (TLTChatHistoryController *)service
{
    if (service == nil)
        service = [[TLTChatHistoryController alloc] initWithDelegate:self];
    return service;
}

- (void)newChatWindow
{
    [self.navigationController pushViewController:
        [[TLRosterViewController alloc] initWithStyle:UITableViewStylePlain]
        animated:YES];
}
@end
