//
//  UseViewController.m
//  RACDemo
//
//  Created by bloodspasm on 2017/7/13.
//  Copyright © 2017年 Ely. All rights reserved.
//

#import "UseViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface UseViewController ()
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmation;
@property (weak, nonatomic) IBOutlet UISwitch *createEnabled;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation UseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
}


/**
 RACObserveFilter 过滤
 */
- (void)RACObserveFilter{
    // 只有当名字的开头为"j"时才打印
    //
    // -filter 只有当block返回YES时才会创建一个新的RACSignal发送一个新值
    [[RACObserve(self, password.text)
      filter:^(NSString *newName) {
          return [newName hasPrefix:@"j"];
      }]
     subscribeNext:^(NSString *newName) {
         NSLog(@"%@", newName);
     }];
}

/**
 RACSignalCombineLatest 监听多值变化
 */
- (void)RACSignalCombineLatest{
    RACSignal *textRAC = [RACSignal combineLatest:@[self.password.rac_textSignal,
                                                    self.passwordConfirmation.rac_textSignal ]reduce:^(NSString *password, NSString *passwordConfirm) {
                                                        NSLog(@"password - %@ passwordConfirm - %@",password,passwordConfirm);
                                                        return @([passwordConfirm isEqualToString:password]);
                                                    } ];
    [textRAC subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}

- (void)baseRAC{
    // 1.代替代理
    // 需求：自定义redView,监听红色view中按钮点击
    // 之前都是需要通过代理监听，给红色View添加一个代理属性，点击按钮的时候，通知代理做事情
    // rac_signalForSelector:把调用某个对象的方法的信息转换成信号，就要调用这个方法，就会发送信号。
    // 这里表示只要redV调用btnClick:,就会发出信号，订阅就好了。
    [[self.view rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id x) {
        NSLog(@"点击红色按钮");
    }];
    
    // 2.KVO
    // 把监听redV的center属性改变转换成信号，只要值改变就会发送信号
    // observer:可以传入nil
    [[self.view rac_valuesAndChangesForKeyPath:@"center" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
    
    // 3.监听事件
    // 把按钮点击事件转换为信号，点击按钮，就会发送信号
    [[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        NSLog(@"按钮被点击了");
    }];
    
    // 4.代替通知
    // 把监听到的通知转换信号
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
    
    // 5.监听文本框的文字改变
    [self.password.rac_textSignal subscribeNext:^(id x) {
        
        NSLog(@"文字改变了%@",x);
    }];
    
    // 6.处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];

}
// 更新UI
- (void)updateUIWithR1:(id)data r2:(id)data1
{
    NSLog(@"更新UI%@  %@",data,data1);
    // VM -> 输出
    // 输入 -> VM
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
