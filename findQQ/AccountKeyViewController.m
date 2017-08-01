
//
//  AccountKeyViewController.m
//  findQQ
//
//  Created by iMacQIU on 2017/5/5.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import "AccountKeyViewController.h"
#import "QYHProgressHUD.h"
#import "NSDictionary+Valkidate.h"
#import "QYHKeyBoardManagerViewController.h"


@interface AccountKeyViewController ()

@property (weak, nonatomic) IBOutlet UITextView *accountTextView;

@property (weak, nonatomic) IBOutlet UITextView *keysTextView;





@end

@implementation AccountKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    self.accountTextView.text = [user objectForKey:@"accountTextView"];
    self.keysTextView.text = [user objectForKey:@"keysTextView"];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [QYHKeyBoardManagerViewController shareInstance].selfView = self.view;
}


- (IBAction)sureAction:(id)sender {
    
    if (self.accountTextView.text.length < 5) {
        [QYHProgressHUD showErrorHUD:nil message:@"请输入要登陆的QQ号码"];
        return;
    }
    
    
    if (self.keysTextView.text.length < 1) {
        [QYHProgressHUD showErrorHUD:nil message:@"请输入要登陆的QQ号码密码"];
        return;
    }
    
    
    if ([self.accountTextView.text containsString:@"，"]) {
        self.accountTextView.text = [self.accountTextView.text stringByReplacingOccurrencesOfString:@"，" withString:@","];
    }
    
    if ([self.keysTextView.text containsString:@"，"]) {
        self.keysTextView.text = [self.keysTextView.text stringByReplacingOccurrencesOfString:@"，" withString:@","];
    }
    
    self.accountTextView.text = [self.accountTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.keysTextView.text = [self.keysTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    NSMutableArray *accoutArrM = [[self.accountTextView.text componentsSeparatedByString:@","] mutableCopy];
    
    if ([accoutArrM containsObject:@""]) {
        [accoutArrM removeObject:@""];
    }
    
    
    NSMutableArray *keysArrM = [[self.keysTextView.text componentsSeparatedByString:@","] mutableCopy];
    
    if ([keysArrM containsObject:@""]) {
        [keysArrM removeObject:@""];
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:[self.accountTextView.text mutableCopy] forKey:@"accountTextView"];
    [user setObject:[self.keysTextView.text mutableCopy] forKey:@"keysTextView"];
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.block) {
            self.block([accoutArrM mutableCopy], [keysArrM mutableCopy]);
        }
    }];
    
}


-(void)setBlock:(GetAccountAndKeys)block{
    _block =block;
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
