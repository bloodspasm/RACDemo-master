//
//  ViewController.m
//  RACDemo
//
//  Created by Eli on 15/12/21.
//  Copyright © 2015年 Ely. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "LxDBAnything.h"
#import "UseViewController.h"
@interface ViewController ()
@property (strong, nonatomic) NSString *valueA;
@property (strong, nonatomic) NSString *valueB;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*******************************第一部分----简单使用*******************************/
    //文本框事件：
    [self textFiledTest];
    //手势
//    [self gestureTest];
    //通知
//    [self notificationTest];
    //定时器NSTime
//    [self timeTest];
    //代理 (有局限，只能取代没有返回值的代理方法)
//    [self delegateTest];
    //KVO
//    [self kvoTest];
    //数据绑定
    [self banding];
    /*******************************第二部分----进阶*******************************/
    //信号 （创建信号 & 激活信号 & 废弃信号）
//    [self createSignal];
    //信号的处理
    //map (映射)和filter
//    [self mapAndFilter];
    //delay延迟
//    [self delay];
    //最先开始的时候
//    [self startWith];
    //超时
//    [self timeOut];
    //take skip
//    [self takeOrSkip];
    //throttle(截流)  结合即时搜索优化来讲
//    [self throttle];
    //repeat 重复
//    [self repeatTest];
    //merge 合并信号
//    [self mergeTest];
    //RAC(TARGET, ...) 宏
//    [self RAC];
    //rac做一个秒表
//    [self stopwatch];
    
    
    //压缩同合并     ab: ab=>
//    [self zipWith];
    //活合并       ab: a=> b=>
//    [self merge];
    //过滤合并      ab: b=>
//    [self then];
    //顺序合并      ab: a->b=>
//    [self concat];
}

- (IBAction)_actionNextVC:(id)sender {
    UseViewController * view = [[UseViewController alloc]init];
    [self.navigationController pushViewController:view animated:YES];

}


- (void)banding{
    RACChannelTerminal *channelA = RACChannelTo(self, valueA);
    RACChannelTerminal *channelB = RACChannelTo(self, valueB);
    [[channelA map:^id(NSString *value) {
            if ([value isEqualToString:@"西"]) {
                    return @"东";
                }
            return value;
        }] subscribe:channelB];
    [[channelB map:^id(NSString *value) {
            if ([value isEqualToString:@"左"]) {
                    return @"右";
                }
            return value;
        }] subscribe:channelA];
    
    [RACObserve(self, valueA) subscribeNext:^(NSString* x) {
        NSLog(@"你向%@", x);
    }];
    [RACObserve(self, valueB) subscribeNext:^(NSString* x) {
        NSLog(@"他向%@", x);
    }];
    self.valueA = @"西";
    self.valueB = @"左";
}
    
#pragma mark - concat 顺序合并
// concat----- 使用需求：有两部分数据：想让上部分先执行，完了之后再让下部分执行（都可获取值）
- (void)concat {
    // 组合
    
    // 创建信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        //        NSLog(@"----发送上部分请求---afn");
        
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted]; // 必须要调用sendCompleted方法！
        return nil;
    }];
    
    // 创建信号B，
    RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        //        NSLog(@"--发送下部分请求--afn");
        [subscriber sendNext:@"下部分数据"];
        return nil;
    }];
    
    
    // concat:按顺序去链接
    //**-注意-**：concat，第一个信号必须要调用sendCompleted
    // 创建组合信号
    RACSignal *concatSignal = [signalA concat:signalsB];
    // 订阅组合信号
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}
    
#pragma mark - zipWith 只有当两个信号同时发出信号内容时
- (void)zipWith {
    //zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元祖，才会触发压缩流的next事件。
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    // 创建信号B
    RACSubject *signalB = [RACSubject subject];
    // 压缩成一个信号
    // **-zipWith-**: 当一个界面多个请求的时候，要等所有请求完成才更新UI
    // 等所有信号都发送内容的时候才会调用
    RACSignal *zipSignal = [signalA zipWith:signalB];
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@", x); //所有的值都被包装成了元组
    }];
    
    // 发送信号 交互顺序，元组内元素的顺序不会变，跟发送的顺序无关，而是跟压缩的顺序有关[signalA zipWith:signalB]---先是A后是B
    [signalA sendNext:@1];
    [signalB sendNext:@2];
    
}
    
#pragma mark - merge 多个信号合并成一个信号，任何一个信号有新值就会调用
// 任何一个信号请求完成都会被订阅到
// merge:多个信号合并成一个信号，任何一个信号有新值就会调用
- (void)merge {
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    // 创建信号B
    RACSubject *signalB = [RACSubject subject];
    //组合信号
    RACSignal *mergeSignal = [signalA merge:signalB];
    // 订阅信号
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号---交换位置则数据结果顺序也会交换
    [signalB sendNext:@"下部分"];
    [signalA sendNext:@"上部分"];
}

#pragma mark - then
// then --- 使用需求：有两部分数据：想让上部分先进行网络请求但是过滤掉数据，然后进行下部分的，拿到下部分数据
- (void)then {
    // 创建信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"----发送上部分请求---afn");
        
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted]; // 必须要调用sendCompleted方法！
        return nil;
    }];
    
    // 创建信号B，
    RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"--发送下部分请求--afn");
        [subscriber sendNext:@"下部分数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    // 创建组合信号
    // then;忽略掉第一个信号的所有值
    RACSignal *thenSignal = [signalA then:^RACSignal *{
        // 返回的信号就是要组合的信号
        return signalsB;
    }];
    
    // 订阅信号
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
}
    
#pragma mark stopwatch
- (void)stopwatch
{
    UILabel * label = ({
       
        UILabel * label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor cyanColor];
        label;
    });
    [self.view addSubview:label];
    
    @weakify(self);
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.size.mas_equalTo(CGSizeMake(240, 40));
        make.center.equalTo(self.view);
        
    }];
    
    RAC(label, text) = [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] map:^NSString *(NSDate * date) {
        
        return date.description;
    }];
}
#pragma mark Rac
- (void)RAC
{
    //button setBackgroundColor:forState:
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:button];
    
    @weakify(self);
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.center.equalTo(self.view);
    }];
    
    /**
      RAC:把一个对象的某个属性绑定一个信号,只要发出信号,就会把信号的内容给对象的属性赋值
      给label的text属性绑定了文本框改变的信号
        RAC(self.label, text) = self.textField.rac_textSignal;
         [self.textField.rac_textSignal subscribeNext:^(id x) {
             self.label.text = x;
         }];
     */
    RAC(button, backgroundColor) = [RACObserve(button, selected) map:^UIColor *(NSNumber * selected) {
        return [selected boolValue] ? [UIColor redColor] : [UIColor greenColor];
    }];
    
    //rac_valuesForKeyPath:
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(UIButton * btn) {  
        btn.selected = !btn.selected;
    }];

}
#pragma mark - RACSignal
    
/**
 RACSignal使用步骤：
 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
 2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
 3.发送信号 - (void)sendNext:(id)value
 
 RACSignal底层实现：
 1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
 2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
 2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
 2.1 subscribeNext内部会调用siganl的didSubscribe
 3.siganl的didSubscribe中调用[subscriber sendNext:@1];
 3.1 sendNext底层其实就是执行subscriber的nextBlock
 
 *  总结：
 我们完全可以用RACSubject代替代理/通知，确实方便许多
 这里我们点击TwoViewController的pop的时候将字符串"ws"传给了ViewController的button的title。
 步骤：
 // 1.创建信号
 RACSubject *subject = [RACSubject subject];
 
 // 2.订阅信号
 [subject subscribeNext:^(id x) {
 // block:当有数据发出的时候就会调用
 // block:处理数据
 NSLog(@"%@",x);
 }];
 
 // 3.发送信号
 [subject sendNext:value];
 **注意：~~**
 RACSubject和RACReplaySubject的区别
 RACSubject必须要先订阅信号之后才能发送信号，而RACReplaySubject可以先发送信号后订阅.
 RACSubject 代码中体现为：先走TwoViewController的sendNext，后走ViewController的subscribeNext订阅
 RACReplaySubject 代码中体现为：先走ViewController的subscribeNext订阅，后走TwoViewController的sendNext
 可按实际情况各取所需。

 */
    

//- (void)mergeTest
//{
//    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            LxPrintAnything(a);
//            [subscriber sendNext:@"a"];
//            [subscriber sendCompleted];
//        });
//        
//        return nil;
//    }];
//    
//    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            LxPrintAnything(b);
//            [subscriber sendNext:@"b"];
//            [subscriber sendCompleted];
//        });
//        
//        return nil;
//    }];
//    //merge 合并  concat 链接  zipWith
//    [[RACSignal concat:@[signalA, signalB]]subscribeNext:^(id x) {
//        
//        LxDBAnyVar(x);
//    }];
//    
//    [[signalA combineLatestWith:signalB]subscribeNext:^(id x) {
//        
//        LxDBAnyVar(x);
//    }];
    
//    [[RACSignal combineLatest:@[signalA, signalB]]subscribeNext:^(id x) {
//        
//        LxDBAnyVar(x);
//    }];
//}
#pragma  mark repeat
- (void)repeatTest
{
    //repeat:
    [[[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"rac"];
        [subscriber sendCompleted];
        
        return nil;
    }]delay:1]repeat]take:3] subscribeNext:^(id x) {
	       
        LxDBAnyVar(x);
    } completed:^{
        
        LxPrintAnything(completed);
    }];

}
#pragma mark  throttle
- (void)throttle
{
    UITextField * textField = [[UITextField alloc]init];
    textField.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:textField];
    
    @weakify(self);
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.center.equalTo(self.view);
    }];
    //throttle 后面是个时间 表示rac_textSignal发送消息，0.3秒内没有再次发送就会相应，若是0.3内又发送消息了，便会在新的信息处重新计时
    //distinctUntilChanged 表示两个消息相同的时候，只会发送一个请求
    //ignore 表示如果消息和ignore后面的消息相同，则会忽略掉这条消息，不让其发送
    
    [[[[[[textField.rac_textSignal throttle:0.3] distinctUntilChanged] ignore:@""] map:^id(id value) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            //  network request
            [subscriber sendNext:value];
            [subscriber sendCompleted];
            
            return [RACDisposable disposableWithBlock:^{
                
                //  cancel request
            }];
        }];
    }]switchToLatest] subscribeNext:^(id x) {
        
        LxDBAnyVar(x);
    }];

    
}
#pragma mark takeOrSkip
- (void)takeOrSkip
{
    RACSignal * signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"rac1"];
        [subscriber sendNext:@"rac2"];
        [subscriber sendNext:@"rac3"];
        [subscriber sendNext:@"rac4"];
        [subscriber sendCompleted];
        return nil;
    }]take:2];//Skip takeLast  takeUntil   takeWhileBlock:   skipWhileBlock:  skipUntilBlock:


    [signal subscribeNext:^(id x) {
        LxDBAnyVar(x);
    }];
}
#pragma mark timeOut
- (void)timeOut
{
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler mainThreadScheduler]afterDelay:3 schedule:^{
            
            [subscriber sendNext:@"rac"];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }] timeout:2 onScheduler:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
         
         LxDBAnyVar(x);
     } error:^(NSError *error) {
         
         LxDBAnyVar(error);
     } completed:^{
         
         LxPrintAnything(completed);
     }];

}
#pragma mark startWith
- (void)startWith
{
    RACSignal * signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
//        [subscriber sendNext:@"123"];//startWith:@"123"等同于这句话 也就是第一个发送，主要是位置
        [subscriber sendNext:@"rac"];
        [subscriber sendCompleted];
        return nil;
    }]startWith:@"123"];
    LxPrintAnything(start);
    //创建订阅者
    [signal subscribeNext:^(id x) {
        LxDBAnyVar(x);
    }];

}
#pragma mark delay
- (void)delay
{
    //创建信号
    RACSignal * signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"rac"];
        [subscriber sendCompleted];
        return nil;
    }]delay:2];
    LxPrintAnything(start);
    //创建订阅者
    [signal subscribeNext:^(id x) {
        LxDBAnyVar(x);
    }];
    
}
#pragma mark map (映射)和filter
- (void)mapAndFilter
{
    UITextField * textField = ({
        UITextField * textField = [[UITextField alloc]init];
        textField.backgroundColor = [UIColor cyanColor];
        
        textField;
    });
    [self.view addSubview:textField];
    
    @weakify(self); //  __weak __typeof__(self) self_weak_ = self;
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);    // __strong __typeof__(self) self = self_weak_;
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.center.equalTo(self.view);
    }];

    [[[textField.rac_textSignal map:^id(NSString *text) {
        
       LxDBAnyVar(text);
        
        return @(text.length);
        
    }]filter:^BOOL(NSNumber *value) {
        
        return value.integerValue > 3;
        
    }] subscribeNext:^(id x) {
         LxDBAnyVar(x);
    }];

}
#pragma mark Signal
- (RACSignal *)createSignal
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        RACDisposable * schedulerDisposable = [[RACScheduler mainThreadScheduler]afterDelay:2 schedule:^{
            
            if (arc4random()%10 > 1) {
                
                [subscriber sendNext:@"Login response"];
                [subscriber sendCompleted];
            }
            else {
                
                [subscriber sendError:[NSError errorWithDomain:@"LOGIN_ERROR_DOMAIN" code:444 userInfo:@{}]];
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{
            
            [schedulerDisposable dispose];
        }];
    }];
}

#pragma mark KVO
/**    
 *  KVO
 *  RACObserveL:快速的监听某个对象的某个属性改变
 *  返回的是一个信号,对象的某个属性改变的信号
    
- (void)test2 {
    [RACObserve(self.view, center) subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}
- (void)testAndtest2 // textField输入的值赋值给label，监听label文字改变,
    {
        
        RAC(self.label, text) = self.textField.rac_textSignal;
        [RACObserve(self.label, text) subscribeNext:^(id x) {
            NSLog(@"====label的文字变了");
        }];  
}      
     */
- (void)kvoTest
{
    UIScrollView * scrollView = [[UIScrollView alloc]init];
    scrollView.delegate = (id<UIScrollViewDelegate>)self;
    [self.view addSubview:scrollView];
    
    UIView * scrollViewContentView = [[UIView alloc]init];
    scrollViewContentView.backgroundColor = [UIColor yellowColor];
    [scrollView addSubview:scrollViewContentView];
    
    @weakify(self);
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(80, 80, 80, 80));
    }];
    
    [scrollViewContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.edges.equalTo(scrollView);
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)));
    }];
    
    [RACObserve(scrollView, contentOffset) subscribeNext:^(id x) {
        
        LxDBAnyVar(x);
    }];
    
//  （好处：写法简单，keypath有代码提示）
}
#pragma mark 代理
- (void)delegateTest
{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"RAC" message:@"ReactiveCocoa" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ensure", nil];
    
    [[self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:) fromProtocol:@protocol(UIAlertViewDelegate)] subscribeNext:^(RACTuple * tuple) {
        
        LxDBAnyVar(tuple);
        
        LxDBAnyVar(tuple.first);
        LxDBAnyVar(tuple.second);
        LxDBAnyVar(tuple.third);
    }];
    [alertView show];
    
    
    //	更简单的方式：
    [[alertView rac_buttonClickedSignal]subscribeNext:^(id x) {
        
        LxDBAnyVar(x);
    }];

}
#pragma mark 定时器
- (void)timeTest
{
    //1. 延迟某个时间后再做某件事
    [[RACScheduler mainThreadScheduler]afterDelay:2 schedule:^{
        
        LxPrintAnything(rac);
    }];
    
    //2. 每间隔多长时间做一件事
    [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSDate * date) {
        
        LxDBAnyVar(date);
    }];

}
#pragma mark 通知
- (void)notificationTest
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil] subscribeNext:^(NSNotification * notification) {
        
        LxDBAnyVar(notification);
    }];
    //不需要removeObserver
}
#pragma mark 手势
- (void)gestureTest
{
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    [[tap rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer * tap) {
        
        LxDBAnyVar(tap);
    }];
    [self.view addGestureRecognizer:tap];
}
#pragma mark 文本框事件
- (void)textFiledTest{
    
    UITextField * textField = ({
        UITextField * textField = [[UITextField alloc]init];
        textField.backgroundColor = [UIColor cyanColor];
        
        textField;
    });
   [self.view addSubview:textField];
    
    @weakify(self); //  __weak __typeof__(self) self_weak_ = self;
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);    // __strong __typeof__(self) self = self_weak_;
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.center.equalTo(self.view);
    }];
    
    [[textField rac_signalForControlEvents:UIControlEventEditingChanged]
     subscribeNext:^(id x) {
         
         LxDBAnyVar(x);
     }];
    //更简单的方式
    [textField.rac_textSignal subscribeNext:^(NSString *x) {
        
        LxDBAnyVar(x);
    }];
}
#pragma mark 缩键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
