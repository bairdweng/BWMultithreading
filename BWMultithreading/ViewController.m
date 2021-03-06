//
//  ViewController.m
//  BWMultithreading
//
//  Created by bairdweng on 2021/7/2.
//

#import "ViewController.h"
#import "GCDViewController.h"
#import "ThreadViewController.h"
#import "BWWildPointerViewController.h"
#import "BWFMDBViewController.h"
#import <YYCache.h>
static NSString *cellId = @"testCellId";
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,strong) NSArray *items;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:cellId];

	// Do any additional setup after loading the view.
}

- (NSArray *)items {
	if (!_items) {
		_items = @[@"GCD",@"NSThread",@"多线程导致野指针",@"多线程与FMDB"];
	}
	return _items;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
	cell.textLabel.text = self.items[indexPath.row];
	return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	switch (indexPath.row) {
	case 0: {
		GCDViewController *gcdVc = [GCDViewController new];
		[self.navigationController pushViewController:gcdVc animated:YES];
	}
	break;
	case 1: {
		ThreadViewController *threadVc = [[ThreadViewController alloc]init];
		[self.navigationController pushViewController:threadVc animated:YES];
	}
	break;
	case 2: {
		BWWildPointerViewController * vc = [[BWWildPointerViewController alloc]init];
		[self.navigationController pushViewController:vc animated:YES];
	}
	break;
	case 3: {
		BWFMDBViewController *vc = [[BWFMDBViewController alloc]init];
		[self.navigationController pushViewController:vc animated:YES];
	}
	default:
		break;
	}
}

@end
