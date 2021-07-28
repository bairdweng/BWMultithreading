//
//  GCDViewController.m
//  BWMultithreading
//
//  Created by bairdweng on 2021/7/2.
//

#import "GCDViewController.h"

@interface GCDViewController () {
	dispatch_queue_t _serialQueue;
	dispatch_queue_t _concurrentQueue;
	dispatch_semaphore_t _semaphoreLock;
}

@property(nonatomic,assign) NSInteger index;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property(nonatomic, strong) NSString *imageUrl1;
@property(nonatomic, strong) NSString *imageUrl2;
@property(nonatomic, assign) int ticketSurplusCount;

@end

@implementation GCDViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	_serialQueue = dispatch_queue_create("com.baird.serial", DISPATCH_QUEUE_SERIAL);
	_concurrentQueue = dispatch_queue_create("com.baird.concurrent", DISPATCH_QUEUE_CONCURRENT);
	// Do any additional setup after loading the view from its nib.
}

#pragma mark Actions
- (IBAction)clean:(id)sender {
	self.imageView.image = nil;
	self.imageView2.image = nil;
}

#pragma mark 全局队列
- (IBAction)clickOntheGlobal:(id)sender {
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		[self loadImageView:self.imageUrl1];
		[self loadImageView2:self.imageUrl2];
	});
}

- (IBAction)clickOntheGlobalSort:(id)sender {
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		dispatch_sync(dispatch_get_global_queue(0, 0), ^{
			[self loadImageView2:self.imageUrl2];
		});
		dispatch_sync(dispatch_get_global_queue(0, 0), ^{
			[self loadImageView:self.imageUrl1];
		});
	});
}

#pragma mark 主队列
// 主线程同步，GG
- (IBAction)clickOnMainSync:(id)sender {
	dispatch_sync(dispatch_get_main_queue(), ^{
		[self loadImageView:self.imageUrl1];
	});
	dispatch_sync(dispatch_get_main_queue(), ^{
		[self loadImageView2:self.imageUrl2];
	});
}
- (IBAction)clickOntheMain:(id)sender {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self loadImageView:self.imageUrl1];
		[self loadImageView2:self.imageUrl2];
	});
}

#pragma mark 串行队列
- (IBAction)clickOnSerialQueue:(id)sender {
	dispatch_async(_serialQueue, ^{
		NSLog(@"串行队列1：%@",[NSThread currentThread]);
		[self loadImageView:self.imageUrl1];
	});
	dispatch_async(_serialQueue, ^{
		NSLog(@"串行队列2：%@",[NSThread currentThread]);
		[self loadImageView2:self.imageUrl2];
	});
}

// 同步串行
- (IBAction)clickOnSyncSerial:(id)sender {
	dispatch_sync(_serialQueue, ^{
		[self loadImageView:self.imageUrl1];
	});
	dispatch_sync(_serialQueue, ^{
		[self loadImageView2:self.imageUrl2];
	});
}

#pragma mark 并行队列
- (IBAction)clickOnConcurrent:(id)sender {
	dispatch_async(_concurrentQueue, ^{
		NSLog(@"并行队列1：%@",[NSThread currentThread]);
		[self loadImageView:self.imageUrl1];
	});
	dispatch_async(_concurrentQueue, ^{
		NSLog(@"并行队列2：%@",[NSThread currentThread]);
		[self loadImageView2:self.imageUrl2];
	});
}

// 同步并行
- (IBAction)clickOnSyncConcurrent:(id)sender {
	dispatch_sync(_concurrentQueue, ^{
		[self loadImageView:self.imageUrl1];
	});
	dispatch_sync(_concurrentQueue, ^{
		[self loadImageView2:self.imageUrl2];
	});
}


#pragma mark 队列组
- (IBAction)notification:(id)sender {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
		dispatch_group_t group = dispatch_group_create();
		__block UIImage *image1 = nil;
		__block UIImage *image2 = nil;
		dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			image1 = [self loadImage:self.imageUrl1];
		});
		dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			image2 = [self loadImage:self.imageUrl2];
		});
		dispatch_group_notify(group, dispatch_get_main_queue(), ^{
			self.imageView.image = image1;
			self.imageView2.image = image2;
		});
	});
}


- (IBAction)groupWait:(id)sender {
	NSLog(@"currentThread---%@",[NSThread currentThread]);
	NSLog(@"group---begin");
	dispatch_group_t group =  dispatch_group_create();
	dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"1---%@",[NSThread currentThread]);
	});

	dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"2---%@",[NSThread currentThread]);
	});
	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
	NSLog(@"group---end");
}


- (IBAction)enterLeave:(id)sender {
	dispatch_group_t group = dispatch_group_create();
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_group_enter(group);
	dispatch_async(queue, ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"1---%@",[NSThread currentThread]);
		dispatch_group_leave(group);
	});
	dispatch_group_enter(group);
	dispatch_async(queue, ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"2---%@",[NSThread currentThread]);
		dispatch_group_leave(group);
	});

	dispatch_group_notify(group, dispatch_get_main_queue(), ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"3---%@",[NSThread currentThread]);
		NSLog(@"group---end");
	});
}

#pragma mark 信号量
- (IBAction)semaphoreSync:(id)sender {
	NSLog(@"currentThread---%@",[NSThread currentThread]);
	NSLog(@"semaphore---begin");
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	__block int number = 0;
	dispatch_async(queue, ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"1---%@",[NSThread currentThread]);
		number = 100;
		dispatch_semaphore_signal(semaphore);
	});
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	NSLog(@"semaphore---end,number = %d",number);
}


- (IBAction)clickOnTheSemaphoreLock:(id)sender {
	NSLog(@"currentThread---%@",[NSThread currentThread]); // 打印当前线程
	NSLog(@"semaphore---begin");
	_semaphoreLock = dispatch_semaphore_create(1);
	self.ticketSurplusCount = 50;
	// queue1 代表北京火车票售卖窗口
	dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
	// queue2 代表上海火车票售卖窗口
	dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
	__weak typeof(self) weakSelf = self;
	dispatch_async(queue1, ^{
		[weakSelf saleTicketSafe];
	});
	dispatch_async(queue2, ^{
		[weakSelf saleTicketSafe];
	});
}

- (void)saleTicketSafe {
	while (1) {
		// 相当于加锁
		dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
		if (self.ticketSurplusCount > 0) { // 如果还有票，继续售卖
			self.ticketSurplusCount--;
			NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
			[NSThread sleepForTimeInterval:0.2];
		} else { // 如果已卖完，关闭售票窗口
			NSLog(@"所有火车票均已售完");
			// 相当于解锁
			dispatch_semaphore_signal(_semaphoreLock);
			break;
		}
		// 相当于解锁
		dispatch_semaphore_signal(_semaphoreLock);
	}
}


#pragma mark 其它
// 快速迭代
- (IBAction)fastIterative:(id)sender {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	NSLog(@"apply---begin");
	dispatch_apply(6, queue, ^(size_t index) {
		NSLog(@"%zd---%@",index, [NSThread currentThread]);
	});
	NSLog(@"apply---end");
}

// 栏栅
- (IBAction)barrierAsync:(id)sender {
	dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);

	dispatch_async(queue, ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"1---%@",[NSThread currentThread]);
	});
	dispatch_async(queue, ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"2---%@",[NSThread currentThread]);
	});

	dispatch_barrier_async(queue, ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"barrier---%@",[NSThread currentThread]);
	});

	dispatch_async(queue, ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"3---%@",[NSThread currentThread]);
	});
	dispatch_async(queue, ^{
		[NSThread sleepForTimeInterval:2];
		NSLog(@"4---%@",[NSThread currentThread]);
	});
}


#pragma mark 加载图片
-(UIImage *)loadImage:(NSString *)url {
	NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	UIImage *image = [UIImage imageWithData:imgData];
	if (image!=nil) {
		return image;
	}else{
		NSLog(@"there no image data");
		return image;
	}
}

- (void)loadImageView:(NSString *)url {
	NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	UIImage *image = [UIImage imageWithData:imgData];
	if (imgData!=nil) {
		[self performSelectorOnMainThread:@selector(refreshImageView:) withObject:image waitUntilDone:YES];
	}else{
		NSLog(@"there no image data");
	}
}

- (void)loadImageView2:(NSString *)url {
	NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	UIImage *image = [UIImage imageWithData:imgData];
	if (imgData!=nil) {
		[self performSelectorOnMainThread:@selector(refreshImageView2:) withObject:image waitUntilDone:YES];
	}else{
		NSLog(@"there no image data");
	}
}

-(void)refreshImageView:(UIImage *)image {
	[self.imageView setImage:image];
}

-(void)refreshImageView2:(UIImage *)image {
	[self.imageView2 setImage:image];
}

#pragma mark Getters
- (NSString *)imageUrl1 {
	return @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fstatic-bbs.nubia.cn%2Fforum%2F201301%2F16%2F2218300z9rssr8p8j8kyr4.jpg&refer=http%3A%2F%2Fstatic-bbs.nubia.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1630044702&t=d56112ffed3ba1c7d36ee4eb3f5c00bf";
}

- (NSString *)imageUrl2 {
	return @"https://pics2.baidu.com/feed/d31b0ef41bd5ad6e87ff3cdcb062e7d3b6fd3c37.jpeg?token=b85201111ec38ef17a39923b2d35a29c";
}

@end
