//
//  BWFMDBViewController.m
//  BWMultithreading
//
//  Created by bairdweng on 2021/10/12.
//

#import "BWFMDBViewController.h"
#define dataBasePath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.sqlite"]

#import <FMDB.h>
#import <YYCache.h>
#import "BWUserObj.h"
@interface BWFMDBViewController ()

@property(nonatomic, strong) FMDatabaseQueue *queue;
@property(nonatomic, assign) BOOL finished;

@end

@implementation BWFMDBViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.finished = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.finished = YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view from its nib.
}

- (IBAction)createTable:(id)sender {
	[self.queue inDatabase:^(FMDatabase * _Nonnull db) {
	         [db executeUpdate:@"create table if not exists test (a text, b text, c text, d text, e text, f text, g text, h text, i text)"];
	 }];
}

- (IBAction)writeData:(id)sender {
	[self whiteToDataBase];
}

- (IBAction)readData:(id)sender {

	[self readDataBase];
}

- (void)readDataBase {
	if (self.finished) {
		return;
	}
	// 多线程查询数据库
	for (int i = 0; i < 1000; i++) {
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			__block BWUserObj *userObj = nil;
			[self getQueryBlock:^(FMResultSet *result) {
			         if ([result next]) {
					 userObj = [[BWUserObj alloc]init];
					 userObj.name = [result stringForColumn:@"a"];
				 }
			 }];
		});
	}
	NSLog(@"正在读取");
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self readDataBase];
	});
}


- (void)whiteToDataBase {
	if (self.finished) {
		return;
	}
	for (int i = 0; i < 1000; i++) {
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			[self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
			         [db executeUpdate:@"insert into test (a, b, c, d, e, f, g, h, i) values ('1', '1', '1','1', '1', '1','1', '1', '1')"];
			 }];
		});
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self whiteToDataBase];
	});
	NSLog(@"正在写入");
}


- (void)getQueryBlock:(void (^)(FMResultSet * result))block {
	[self.queue inDatabase:^(FMDatabase * _Nonnull db) {
	         FMResultSet *result = [db executeQuery:@"select * from test where a = '1'"];
	         block(result);
	         [result close];
	 }];
}

- (FMDatabaseQueue *)queue {
	if (!_queue) {
		_queue = [[FMDatabaseQueue alloc]initWithPath:dataBasePath];
	}
	return _queue;
}

- (void)dealloc {
	NSLog(@"dealloc=%@",NSStringFromClass([self class]));
}


@end
