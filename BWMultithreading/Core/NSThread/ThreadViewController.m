//
//  ThreadViewController.m
//  BWMultithreading
//
//  Created by bairdweng on 2021/7/29.
//

#import "ThreadViewController.h"

static NSString *imgUrl = @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fstatic-bbs.nubia.cn%2Fforum%2F201301%2F16%2F2218300z9rssr8p8j8kyr4.jpg&refer=http%3A%2F%2Fstatic-bbs.nubia.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1630044702&t=d56112ffed3ba1c7d36ee4eb3f5c00bf";

@interface ThreadViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ThreadViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

//动态创建线程
-(IBAction)dynamicCreateThread:(id)sender {
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImageSource:) object:imgUrl];
	// 设置线程的优先级(0.0 - 1.0，1.0最高级)
	thread.threadPriority = 1;
	[thread start];
}

//静态创建线程
-(IBAction)staticCreateThread:(id)sender {
	[NSThread detachNewThreadSelector:@selector(loadImageSource:) toTarget:self withObject:imgUrl];
}

//隐式创建线程
-(IBAction)implicitCreateThread:(id)sender {
	[self performSelectorInBackground:@selector(loadImageSource:) withObject:imgUrl];
}

- (IBAction)cleanImageView:(id)sender {
	self.imageView.image = nil;
}


-(void)loadImageSource:(NSString *)url {
	NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	UIImage *image = [UIImage imageWithData:imgData];
	if (imgData!=nil) {
		[self performSelectorOnMainThread:@selector(refreshImageView:) withObject:image waitUntilDone:YES];
	}else{
		NSLog(@"there no image data");
	}
}

-(void)refreshImageView:(UIImage *)image {
	[self.imageView setImage:image];
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
