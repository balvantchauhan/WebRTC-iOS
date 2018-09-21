

#import "ListPeopleViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
@interface ListPeopleViewController () {
    NSArray *resultArray;
    UIRefreshControl *refreshControl;
}

@end

@implementation ListPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://122.161.193.184:3000/streams.json"]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil)
    {
        // Parse data here
        NSError* error;
        resultArray = [[NSArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:data
                                                                                     options:kNilOptions
                                                                                       error:&error]];
        [self.tableView reloadData];
        
        NSLog(@"");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newCall:)
                                                 name:kNewCallObserver
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refresh:(UIRefreshControl *)sender {
    [refreshControl beginRefreshing];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://122.161.193.184:3000/streams.json"]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil)
    {
        // Parse data here
        NSError* error;
        resultArray = [[NSArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:data
                                                                                     options:kNilOptions
                                                                                       error:&error]];
        [self.tableView reloadData];
        [refreshControl endRefreshing];
        NSLog(@"");
    }
    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    NSDictionary *dict = [resultArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"name"];
    cell.detailTextLabel.text = [dict objectForKey:@"id"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self appDelegate].object = [[WebRTC alloc] initWithVideo:YES];
    [self appDelegate].object.delegate = [self appDelegate];
    
    NSDictionary *dict = [resultArray objectAtIndex:indexPath.row];
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.needCall = YES;
    vc.callToUser = [dict objectForKey:@"id"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (AppDelegate*)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)newCall:(NSNotification *) notification {
    NSDictionary *dict = notification.userInfo;
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    vc.needCall = NO;
    vc.callToUser = [dict objectForKey:kPeerID];
    [self.navigationController pushViewController:vc animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
