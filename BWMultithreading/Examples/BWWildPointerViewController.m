//
//  BWWildPointerViewController.m
//  BWMultithreading
//
//  Created by bairdweng on 2021/10/8.
//

/*
   多线程只读数据情况下：不会发生Crash；
   多线程只写数据，字典仅有一个key，且多线程读写同一个key的情况下，会发生Crash；
   多线程只写数据，字典有多个key，且多线程同时写不同key的情况下，会发生Crash；
   多线程只写数据，字典有多个key，多线程随机写key的情况下，会发生Crash；
   多线程读写数据的情况下，会发生Crash。
   ————————————————
 */

#import "BWWildPointerViewController.h"
#import <FMDB.h>
#import <YYCache.h>
#import "BWUserObj.h"

@interface BWWildPointerViewController () {

}

// 串行队列
@property(nonatomic, strong) dispatch_queue_t concurrentQueue;


@end

@implementation BWWildPointerViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	_concurrentQueue =  dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
	// Do any additional setup after loading the view from its nib.
}

// 1. 多线程只读数据
- (IBAction)example1:(id)sender {
	NSMutableDictionary * dict1 = [[NSMutableDictionary alloc] init];
	[dict1 setObject:@"test0" forKey:@"test0"];
	[dict1 setObject:@"test1" forKey:@"test1"];
	[dict1 setObject:@"test2" forKey:@"test2"];
	for (int i = 0; i < 1000; i++) {
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			NSString * key = [NSString stringWithFormat:@"test%d", i%3];
			NSString * value = dict1[key];
			NSLog(@"%@:%@", key, value);
		});
	}
}

// 2. 多线程只写数据
// 字典仅有一个key
// 多线程写同一个key
- (IBAction)example2:(id)sender {
	NSMutableDictionary * dict2 = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < 1000; i++) {
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			[dict2 setObject:@(i) forKey:@"test"];
		});
	}
}

// 3. 多线程只写数据
// 字典有多个key
// 多线程同时写不同key
- (IBAction)example3:(id)sender {
	NSMutableDictionary * dict3 = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < 1000; i++) {
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			[dict3 setObject:[NSString stringWithFormat:@"test%d", i] forKey:[NSString stringWithFormat:@"test%d", i]];
		});
	}
}

// 4. 多线程只写数据
// 字典有多个key
// 多线程随机写key
- (IBAction)example4:(id)sender {
	NSMutableDictionary * dict4 = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < 1000; i++) {
		int x = arc4random() % 3;
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			[dict4 setObject:[NSString stringWithFormat:@"test%d", i] forKey:[NSString stringWithFormat:@"test%d", x]];
		});
	}
}

// 5. 多线程读写数据
- (IBAction)example5:(id)sender {
	NSMutableDictionary * dict5 = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < 1000; i++) {
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			[dict5 setObject:[NSString stringWithFormat:@"test%d", i%3] forKey:[NSString stringWithFormat:@"test%d", i%3]];
		});
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			NSString * key = [NSString stringWithFormat:@"test%d", i%3];
			NSString * value = dict5[key];
			NSLog(@"%@:%@", key, value);
		});
	}
}
// 6. 多读单写
- (IBAction)example6:(id)sender {
	NSMutableDictionary * dict5 = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < 1000; i++) {
		dispatch_async(_concurrentQueue, ^{
			[dict5 setObject:[NSString stringWithFormat:@"test%d", i%3] forKey:[NSString stringWithFormat:@"test%d", i%3]];
		});
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			NSString * key = [NSString stringWithFormat:@"test%d", i%3];
			NSString * value = dict5[key];
			NSLog(@"%@:%@", key, value);
		});
	}
}

- (void)dealloc {
	NSLog(@"dealloc=%@",NSStringFromClass([self class]));
}
@end
