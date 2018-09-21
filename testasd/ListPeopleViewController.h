
#import <UIKit/UIKit.h>

@interface ListPeopleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
