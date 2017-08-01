//
//  DifferentViewController.m
//  findQQ
//
//  Created by 邱永槐 on 2017/4/22.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import "DifferentViewController.h"
#import "Userinfo.h"
#import "AFHTTPRequestOperationManager.h"
#import "QYHKeyBoardManagerViewController.h"
#import "QYHProgressHUD.h"
#import "NSDictionary+Valkidate.h"

@interface DifferentViewController ()
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UITextView *outTextView;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UILabel *currenUserQLabel;
@property (weak, nonatomic) IBOutlet UILabel *allUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentQQ;


@property (nonatomic,strong) NSMutableArray *arrM;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,assign) BOOL isCancel;

@property (nonatomic,assign) NSInteger clickIndex;
@property (nonatomic,assign) NSInteger successCount;
@property (nonatomic,assign) NSUInteger searchIndex;

@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;

@end

@implementation DifferentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    Userinfo *userInfo = [Userinfo shareInstance];
    
    if (userInfo.index < userInfo.skeyArray.count) {
        
        NSDictionary *userDic = userInfo.skeyArray[userInfo.index];
        
        if (userDic) {
            self.ouin = [userDic objectForKey:@"uin2"];
            self.skey = [userDic objectForKey:@"skey2"];
            
            self.currenUserQLabel.text = [NSString stringWithFormat:@"正在使用的qq：%@",[self.ouin substringFromIndex:1]];
            self.allUserLabel.text = [NSString stringWithFormat:@"%ld/%ld",(userInfo.index+1),userInfo.skeyArray.count];
        }
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.inputTextView.text = [user objectForKey:@"inputTextView3"];
    
    
    _arrM = [NSMutableArray array];
    
    
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [_manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    [_manager.requestSerializer setValue:[NSString stringWithFormat:@"skey=%@;uin=%@",self.skey,self.ouin] forHTTPHeaderField:@"Cookie"];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [QYHKeyBoardManagerViewController shareInstance].selfView = self.view;
    
    [self.view bringSubviewToFront:self.bgView];
    [self.view bringSubviewToFront:self.checkButton];
    
}


-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
        _bgView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        _bgView.hidden = YES;
        [self.view addSubview:_bgView];
    }
    
    return _bgView;
}




- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)checkAction:(id)sender {
    
    if (self.inputTextView.text.length < 5) {
        [QYHProgressHUD showErrorHUD:nil message:@"请输入要查询的QQ号码"];
        return;
    }
    
    if ([self.inputTextView.text containsString:@"，"]) {
        self.inputTextView.text = [self.inputTextView.text stringByReplacingOccurrencesOfString:@"，" withString:@","];
    }
    
    self.inputTextView.text = [self.inputTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.inputTextView.text = [self.inputTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    NSMutableArray *arrM = [[self.inputTextView.text componentsSeparatedByString:@","] mutableCopy];
    if ([arrM containsObject:@""]) {
        [arrM removeObject:@""];
    }
    
    self.dataArray = [arrM mutableCopy];//2033442473,3536383839
    
    NSLog(@"self.dataArray==%@",self.dataArray);
    
    if (!self.dataArray.count) {
        [QYHProgressHUD showErrorHUD:nil message:@"请输入要查询的QQ号码"];
        return;
    }
    

    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [user setObject:[self.inputTextView.text mutableCopy] forKey:@"inputTextView3"];
    
    [self find:sender];

}


- (void)find:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        //开始
        self.bgView.hidden = NO;
        
        _isCancel = NO;

        [_arrM removeAllObjects];
        [self.view endEditing:YES];
        
        _searchIndex = 0;
        _successCount = 0;
        
        [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *keyNumber = (NSString *)obj;
            [self findQQ:keyNumber];
        }];
        
        
    }else{
        //终止
        [_manager.operationQueue cancelAllOperations];
        self.bgView.hidden = YES;
    }
}

- (void)findQQ:(NSString *)qq{
    
    Userinfo *userInfo = [Userinfo shareInstance];
    
    if (!self.skey || !self.ouin) {
        [QYHProgressHUD showErrorHUD:nil message:@"请登录QQ获取获取参数！！！"];
        return;
    }
    
    __weak typeof(self) weakself = self;
    const NSInteger idx = userInfo.index;
    
    [_manager GET:[NSString stringWithFormat:@"http://haoma.svip.qq.com/cgi-bin/HaomaWrap.fcgi?cmd=GetPayInfo&buyuin=%@",qq] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject==%@",responseObject);
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic = [NSDictionary dictionaryWithJsonString:string];
        
        NSLog(@"string==%@,dic==%@",string,dic);
        
        
        weakself.searchIndex++;
        BOOL isCanpay = NO;
        
        NSDictionary *dataDic = [dic objectForKey:@"data"];
        NSString *ret = [dic objectForKey:@"ret"];
        
        if ([ret integerValue] != 0) {
            
            NSInteger r = [ret integerValue];
            
            if (r == 5) {
                
                Userinfo *userInfo = [Userinfo shareInstance];
                
                
                NSLog(@"userInfo.index==%ld,idx==%ld",userInfo.index,idx);
                
                if (userInfo.index < userInfo.skeyArray.count - 1 || idx < userInfo.index) {
                    if (idx == userInfo.index) {
                        userInfo.index +=1;
                    }
                    
                    NSDictionary *userDic = userInfo.skeyArray[userInfo.index];
                    
                    if (userDic) {
                        weakself.ouin = [userDic objectForKey:@"uin2"];
                        weakself.skey = [userDic objectForKey:@"skey2"];
                        
                        [weakself.manager.requestSerializer setValue:[NSString stringWithFormat:@"skey=%@;uin=%@",weakself.skey,weakself.ouin] forHTTPHeaderField:@"Cookie"];
                        
                        weakself.currenUserQLabel.text = [NSString stringWithFormat:@"正在使用的qq：%@",[weakself.ouin substringFromIndex:1]];
                        weakself.allUserLabel.text = [NSString stringWithFormat:@"%ld/%ld",(userInfo.index+1),userInfo.skeyArray.count];
                    }
                    
                    weakself.searchIndex--;
                    
                    [weakself findQQ:qq];
                    
                }else{
                    weakself.isCancel = YES;
                    [QYHProgressHUD showErrorHUD:nil message:@"服务器限制了，请换另外的QQ号码！！！"];
                    weakself.checkButton.selected = NO;
                    weakself.bgView.hidden = YES;
                    [weakself.manager.operationQueue cancelAllOperations];
                }
                
            }else if (r == -9993){
                weakself.isCancel = YES;
                weakself.checkButton.selected = NO;
                weakself.bgView.hidden = YES;
                [weakself.manager.operationQueue cancelAllOperations];
                [QYHProgressHUD showErrorHUD:nil message:@"查询参数错误"];
                
            }else{
                
                [QYHProgressHUD showErrorHUD:nil message:[NSString stringWithFormat:@"查询QQ号：%@ 出现错误 ,dic==%@",qq,dic]];
                
                if (weakself.searchIndex >= weakself.dataArray.count) {
                    weakself.bgView.hidden = YES;
                    weakself.checkButton.selected = NO;
                    [QYHProgressHUD showSuccessHUD:nil message:@"查询完毕"];
                }
            }
            
            return ;
        }
        
        
        if (dataDic) {
            /*
             ic=={
             data =     {
             actid = "";
             buyuin = 2033442473;
             locktime = 1491082365;
             needmonth = 5;
             numprice = 0;
             numstatus = 2;
             numtype = 10070;
             selflock = 0;
             status = 0;
             };
             msg = ok;
             ret = 0;
             }
             */
           
            NSString *status    = [dataDic objectForKey:@"status"];
            NSString *numtype   = [dataDic objectForKey:@"numtype"];
            NSString *buyuin    = [dataDic objectForKey:@"buyuin"];
            NSString *locktime  = [dataDic objectForKey:@"locktime"];
            NSString *needmonth = [dataDic objectForKey:@"needmonth"];
            NSString *numstatus = [dataDic objectForKey:@"numstatus"];
            
            if (status) {
                if ([status integerValue] == 0) {
                    isCanpay = YES;
                }
            }
            
            if (isCanpay) {
                
                if (locktime && [locktime integerValue]) {
                    
                    NSString *time = [self timeWithTimeIntervalString:locktime];
                    NSString *str = [NSString stringWithFormat:@"%@ --- %@",qq,time];
                    [weakself.arrM addObject:str];
                    weakself.outTextView.text = [weakself.arrM componentsJoinedByString:@"\n"];

                }
                
            }else{
                NSLog(@"%@", [NSString stringWithFormat:@"不满足的QQ==%@",qq]);
            }
            
            weakself.successCount++;
            weakself.currentQQ.text = [NSString stringWithFormat:@"搜索成功数：%ld，总数：%ld",weakself.successCount,weakself.dataArray.count];
            
        }else{
            [QYHProgressHUD showErrorHUD:nil message:[NSString stringWithFormat:@"查询QQ号：%@ 出现错误 ,dic==%@",qq,dic]];
        }

        
        if (weakself.searchIndex >= weakself.dataArray.count) {
            weakself.bgView.hidden = YES;
            weakself.checkButton.selected = NO;
            [QYHProgressHUD showSuccessHUD:nil message:@"查询完毕"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //失败走失败的回调
        
        NSLog(@"error==%@",error);
        
        if (!weakself.isCancel) {

            weakself.bgView.hidden = YES;
            weakself.checkButton.selected = NO;
            [QYHProgressHUD showErrorHUD:nil message:[NSString stringWithFormat:@"查询QQ号：%@,出现错误,error==%@",qq,error]];
            
        }
        
    }];
}

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}


@end
