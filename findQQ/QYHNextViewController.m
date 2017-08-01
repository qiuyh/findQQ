//
//  QYHNextViewController.m
//  findQQ
//
//  Created by iMacQIU on 2017/4/10.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import "QYHNextViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "QYHProgressHUD.h"
#import "NSDictionary+Valkidate.h"
#import "QYHKeyBoardManagerViewController.h"
#import "WebViewController.h"
#import "Userinfo.h"
#import "VipWebViewController.h"
#import "UIImageView+WebCache.h"
#import "ResultViewController.h"
#import "ViewController.h"
#import "DifferentViewController.h"
#import "CustomURLProtocol.h"

@interface QYHNextViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
//@property (weak, nonatomic) IBOutlet UITextView *outTextView;
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,assign) BOOL isEnd;

//@property (nonatomic,copy) NSString *uin;

@property (nonatomic,strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@property (nonatomic,assign) NSInteger count;

@property (nonatomic,strong) NSMutableArray *arrM;
@property (weak, nonatomic) IBOutlet UILabel *currentQQ;
@property (weak, nonatomic) IBOutlet UIImageView *authImageView;

@property (weak, nonatomic) IBOutlet UITextField *authTextField;

@property (nonatomic,assign) NSUInteger searchIndex;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UILabel *currenUserQLabel;
@property (weak, nonatomic) IBOutlet UILabel *allUserLabel;

@property (weak, nonatomic) IBOutlet UILabel *allSearchQLabel;

@property (nonatomic,assign) NSInteger requestCount;
@property (nonatomic,assign) NSInteger clickIndex;

@property (nonatomic,assign) BOOL isNeedClick;//判断搜索慢出来的号要不要自动跳转

//@property (nonatomic,strong) NSMutableArray *resultArrM;

@property (nonatomic,assign) int getqqCount;

@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic,assign) NSInteger successCount;

@property (nonatomic,assign) BOOL isCancel;

@property (nonatomic,assign) BOOL isFirst;


@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (nonatomic,strong) NSMutableArray *selectedIndexArrM;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *firstBtn;

@property (weak, nonatomic) IBOutlet UILabel *qiangGouQQLabel;

@property (weak, nonatomic) IBOutlet UIButton *startActionBtn;

@property (nonatomic,assign) BOOL isStop;

@property (nonatomic,assign) int qiangGouCount;

@end

@implementation QYHNextViewController

-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
        _bgView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        _bgView.hidden = YES;
        [self.view addSubview:_bgView];
    }
    
    return _bgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册protocol
    [NSURLProtocol registerClass:[CustomURLProtocol class]];
    
    self.tableView.tableFooterView = [UIView new];
    
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
    
    if ([user objectForKey:@"phone2"]) {
        _phoneTextField.text = [user objectForKey:@"phone2"];
    }
    if ([user objectForKey:@"password2"]) {
        _passwordTextField.text = [user objectForKey:@"password2"];
    }
    
    self.checkButton.layer.cornerRadius = 5;
    self.checkButton.clipsToBounds = YES;
    
    if (self.dataString && self.dataString.length > 5) {
        self.inputTextView.text = self.dataString;
    }else{
        self.inputTextView.text = [user objectForKey: self.isSecond ? @"inputTextView3" : @"inputTextView"];
    }
    

    self.changeBtn.hidden = self.isSecond;
    self.nextBtn.hidden = self.isSecond;
    [self.firstBtn setTitle:self.isSecond ? @"返回" : @"第一页" forState:UIControlStateNormal];

//    self.skey = @"ZdDSLJljUL";
//    self.ouin = @"o867674248";
    
    _isFirst = YES;
    _isNeedClick = NO;
    _isStop = NO;
    _requestCount = 0;
    _clickIndex = 0;
    _qiangGouCount = 0;
    self.startActionBtn.enabled = NO;

    _arrM = [NSMutableArray array];
    _selectedIndexArrM = [NSMutableArray array];

    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [_manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    [_manager.requestSerializer setValue:[NSString stringWithFormat:@"skey=%@;uin=%@",self.skey,self.ouin] forHTTPHeaderField:@"Cookie"];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [QYHKeyBoardManagerViewController shareInstance].selfView = self.view;
    
    if (_isFirst) {
        _isFirst = NO;
        [self.view bringSubviewToFront:self.bgView];
        [self.view bringSubviewToFront:self.checkButton];
    }
    
    
    if ([Userinfo shareInstance].resultArrM.count) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:[[Userinfo shareInstance].resultArrM mutableCopy] forKey:@"resultInfo"];
        [user synchronize];
    }
    
    if (_isNeedRereshAuth) {
        self.authTextField.text = nil;
        _isNeedRereshAuth = NO;
        [self getAuthCode];
    }

}



- (IBAction)getAuthAction:(id)sender {
    [self getAuthCode];
}



- (void)getAuthCode{
    
//    _requestCount++;
//    
//    if (_requestCount > 3) {
//        _requestCount = 0;
//        return;
//    }
    
//    if (_isStop) {
//        self.startActionBtn.selected = NO;
//        return;
//    }
//    
//    if (_qiangGouCount >= 8) {
//        self.startActionBtn.selected = NO;
//        return;
//    }
    
    NSString *str = @"http://captcha.qq.com/getimage/pvip_hmpay/?appid=8000202";
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
    self.authImageView.image = [UIImage imageWithData:data];
    
    NSString *pictureDataString=[data base64Encoding];
    NSDictionary *parameters = @{@"user":@"fenghuai",
                                 @"pass":@"7720401ABC",
                                 @"softid":@"893354",
                                 @"codetype":@"1901",
                                 @"len_min":@"0",
                                 @"time_add":@"0",
                                 @"str_debug":@"0",
                                 @"file_base64":pictureDataString
                                 };
    
    __weak typeof(self) weakself = self;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    [manager POST:@"http://upload.chaojiying.net/Upload/Processing.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject==%@",responseObject);
        
        
        if (responseObject) {
            NSInteger err_no  = [[responseObject objectForKey:@"err_no"] integerValue];
            NSString *err_str = [responseObject objectForKey:@"err_str"];
            
            if (err_str && err_no == 0 && [err_str isEqualToString:@"OK"]) {
                NSString *pic_id  = [responseObject objectForKey:@"pic_id"];
                NSString *pic_str = [responseObject objectForKey:@"pic_str"];
                
                if (pic_id) {
                    
                }
                
                if (pic_str) {
                    weakself.authTextField.text = pic_str;
                    
//                    NSLog(@"_clickIndex==%ld,_arrM.count==%ld",_clickIndex,_arrM.count);
                    weakself.isNeedClick = YES;
                    if (weakself.clickIndex > 0 && weakself.arrM.count) {
                        if (weakself.clickIndex < weakself.arrM.count) {
//                            if (_isStop) {
//                                self.startActionBtn.selected = NO;
//                                return ;
//                            }
                            weakself.isNeedClick = NO;
                            [weakself.tableView.delegate tableView:weakself.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:weakself.clickIndex inSection:0]];
                        }else{
//                            self.startActionBtn.selected = NO;
                        }
                    }
                    
                    weakself.requestCount = 0;
                   
                }else{
                    [weakself getAuthCode];
                }
            }else{
                [weakself getAuthCode];
            }
        }else{
            [weakself getAuthCode];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error==%@",error);
        
        [weakself getAuthCode];
    }];
}


- (IBAction)cancelAction:(id)sender {
    
    if (self.isSecond ) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        VC.skey = self.skey;
        VC.uin  = self.ouin;
        
        [VC setBlock:^(NSString *dataString) {
            if (dataString.length > 1) {
                self.inputTextView.text = dataString;
            }
        } ];
        
        [self presentViewController:VC animated:YES completion:nil];
    }
    
}

- (IBAction)changeAccount:(id)sender {
    
    WebViewController *webVC = [[WebViewController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = webVC;
}



- (IBAction)findAction:(id)sender {

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

    self.dataArray = [arrM mutableCopy];
    
    NSLog(@"self.dataArray==%@",self.dataArray);
    
    if (!self.dataArray.count) {
        [QYHProgressHUD showErrorHUD:nil message:@"请输入要查询的QQ号码"];
        return;
    }
    
    
    [_selectedIndexArrM removeAllObjects];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if (self.changeBtn.selected) {
        //过滤
         [user setObject:[self.inputTextView.text mutableCopy] forKey:@"inputTextView1"];
        [self getData];
    }else{
        //正常
       
        [user setObject:[self.inputTextView.text mutableCopy] forKey:self.isSecond ? @"inputTextView3" : @"inputTextView"];

        [self find:sender];
    }
}


- (void)getData{
    
    self.arrM = [self.dataArray mutableCopy];
    [self.tableView reloadData];
    
    [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}


- (void)find:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        //开始
        self.bgView.hidden = NO;
        
        _isCancel = NO;
        _isEnd = NO;
        _count = 0;
        [_arrM removeAllObjects];
        [self.tableView reloadData];
        [self.view endEditing:YES];
        
        _searchIndex = 0;
        _getqqCount = 0;
        _successCount = 0;
        
        [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *keyNumber = (NSString *)obj;
            [self findQQ:keyNumber];
        }];
        
        
    }else{
        //终止
        _isEnd = YES;
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
            
            if (r == 5 || r == -9993) {
                
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
                
            }
//            else if (r == -9993){
//                weakself.isCancel = YES;
//                weakself.checkButton.selected = NO;
//                weakself.bgView.hidden = YES;
//                [weakself.manager.operationQueue cancelAllOperations];
//                [QYHProgressHUD showErrorHUD:nil message:@"查询参数错误"];
//                
//            }
            
            
            else{
                
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
             dic=={
             data =     {
             actid = "";
             buyuin = 3456234536;
             locktime = 1483586951;
             needmonth = 1;
             numprice = 0;
             numstatus = 4;
             numtype = 10070;
             selflock = 0;
             status = 2;
             };
             msg = ok;
             ret = 0;
             }
             
             
             dic=={
             data =     {
             actid = "";
             buyuin = 228210086;
             locktime = 1494791339;
             needmonth = 5;
             numprice = 0;
             numstatus = 2;
             numtype = 10070;
             selflock = 0;
             status = 2;
             };
             msg = ok;
             ret = 0;
             }
             
             */
            
            weakself.count = 0;
            NSString *status    = [dataDic objectForKey:@"status"];
            NSString *numtype   = [dataDic objectForKey:@"numtype"];
            NSString *buyuin    = [dataDic objectForKey:@"buyuin"];
            NSString *locktime  = [dataDic objectForKey:@"locktime"];
            NSString *needmonth = [dataDic objectForKey:@"needmonth"];
            NSString *numstatus = [dataDic objectForKey:@"numstatus"];
            
            if (status) {
                if ([status integerValue] == 0) {
                    isCanpay = YES;
                }else{
                    //后来添加的，提示手慢但可以注册的
                    if (numstatus && [numstatus integerValue] == 4  && numtype && [numtype integerValue] == 10070) {
                        isCanpay = YES;
                    }
                }
            }
            
            //判断是否为第二次进来的，区分第一种和第二种的
            
            if (self.isSecond) {
                if (numstatus && [numstatus integerValue] == 4) {
                    isCanpay = YES;
                }else if (locktime && [locktime integerValue] == 0) {
                    isCanpay = isCanpay;
                }else{
                     isCanpay = NO;
                }
            }
            
            if (isCanpay) {

                weakself.getqqCount++;
                [weakself.arrM addObject:qq];
                [weakself.tableView reloadData];
                
                if (weakself.getqqCount == 1) {
                    
//                    _isStop = NO;
//                    _qiangGouCount = 0;
//                    self.startActionBtn.enabled = YES;
//                    self.startActionBtn.selected = YES;
                    
                    weakself.isNeedClick = NO;
                    
                    [weakself.tableView.delegate tableView:weakself.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                }else{
                    if (weakself.isNeedClick) {
                         weakself.isNeedClick = NO;
                        if (weakself.clickIndex < weakself.arrM.count) {
                            [weakself.tableView.delegate tableView:weakself.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:weakself.clickIndex inSection:0]];
                        }
                    }
                }
                
            }else{
                NSLog(@"%@", [NSString stringWithFormat:@"不满足的QQ==%@",qq]);
            }
            
            weakself.successCount++;
            weakself.currentQQ.text = [NSString stringWithFormat:@"搜索成功数：%ld，总数：%ld",weakself.successCount,weakself.dataArray.count];
            weakself.allSearchQLabel.text = @"";

        }else{
               [QYHProgressHUD showErrorHUD:nil message:[NSString stringWithFormat:@"查询QQ号：%@ 出现错误 ,dic==%@",qq,dic]];
        }
        
        NSLog(@"weakself.searchIndex==%ld,,weakself.dataArray.coun==%ld",weakself.searchIndex,weakself.dataArray.count);
        
        if (weakself.searchIndex >= weakself.dataArray.count) {
            weakself.bgView.hidden = YES;
            weakself.checkButton.selected = NO;
            
//            _isStop = NO;
//            _qiangGouCount = 0;
//            self.startActionBtn.enabled = YES;
//            self.startActionBtn.selected = YES;
            
            [QYHProgressHUD showSuccessHUD:nil message:@"查询完毕"];
            
//            if (weakself.getqqCount != 0) {
//                [weakself.tableView.delegate tableView:weakself.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //失败走失败的回调
        
        NSLog(@"error==%@",error);
        
        if (!weakself.isCancel) {
//            weakself.searchIndex++;
            
            weakself.bgView.hidden = YES;
            weakself.checkButton.selected = NO;
            [QYHProgressHUD showErrorHUD:nil message:[NSString stringWithFormat:@"查询QQ号：%@,出现错误,error==%@",qq,error]];
            
//            if (weakself.searchIndex == weakself.dataArray.count) {
//                weakself.bgView.hidden = YES;
//                weakself.checkButton.selected = NO;
//                [QYHProgressHUD showSuccessHUD:nil message:@"查询完毕"];
//            }
        }
        
    }];
}


//kn:1222117980,ldw:257913799,sk:ZdDSLJljUL,in:o867674248


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrM.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"nextCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([_selectedIndexArrM containsObject:@(indexPath.row)]) {
        cell.textLabel.textColor = [UIColor redColor];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.text = [_arrM objectAtIndex:indexPath.row];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.authTextField.text.length != 4) {
        [QYHProgressHUD showErrorHUD:nil message:@"请输入正确的验证码"];
        return;
    }
    
    if (_phoneTextField.text.length == 0) {
        [QYHProgressHUD showErrorHUD:nil message:@"请填写手机号"];
        return;
    }
    
    if (_phoneTextField.text.length != 11) {
        [QYHProgressHUD showErrorHUD:nil message:@"填写手机号不正确"];
        return;
    }
    
    if (_passwordTextField.text.length == 0) {
        [QYHProgressHUD showErrorHUD:nil message:@"请填写注册密码"];
        return;
    }
    
    if (_passwordTextField.text.length < 6) {
        [QYHProgressHUD showErrorHUD:nil message:@"填写密码位数过少"];
        return;
    }
    
    _isNeedRereshAuth = YES;
    _clickIndex = indexPath.row + 1;
    _qiangGouCount++;
    
    [_selectedIndexArrM addObject:@(indexPath.row)];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:_phoneTextField.text forKey:@"phone2"];
    [user setObject:_passwordTextField.text forKey:@"password2"];
    [user synchronize];
    
    
    NSString *phone = [_phoneTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *password = [_passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *auth = [_authTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    VipWebViewController *vipWebView = [[VipWebViewController alloc] init];
    vipWebView.num = [_arrM objectAtIndex:indexPath.row];
    vipWebView.phone = phone;
    vipWebView.password = password;
    vipWebView.authString = auth;
    vipWebView.isFromCache = NO;
    
    self.qiangGouQQLabel.text = [NSString stringWithFormat:@"已经抢购完%@,%ld/%ld",vipWebView.num,(indexPath.row + 1),_arrM.count];
    
    [self presentViewController:vipWebView animated:YES completion:nil];
   
}



- (IBAction)gotoResult:(id)sender {
    
    ResultViewController *resultVC = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];

    if ([Userinfo shareInstance].resultArrM.count) {
         resultVC.dataArray = [[Userinfo shareInstance].resultArrM mutableCopy];
    }

    [self presentViewController:resultVC animated:YES completion:nil];
}

- (IBAction)firstAction:(id)sender {
    
    if (self.authTextField.text.length != 4) {
        [QYHProgressHUD showErrorHUD:nil message:@"请输入正确的验证码"];
        return;
    }
    
    if (_phoneTextField.text.length == 0) {
        [QYHProgressHUD showErrorHUD:nil message:@"请填写手机号"];
        return;
    }
    
    if (_phoneTextField.text.length != 11) {
        [QYHProgressHUD showErrorHUD:nil message:@"填写手机号不正确"];
        return;
    }
    
    if (_passwordTextField.text.length == 0) {
        [QYHProgressHUD showErrorHUD:nil message:@"请填写注册密码"];
        return;
    }
    
    if (_passwordTextField.text.length < 6) {
        [QYHProgressHUD showErrorHUD:nil message:@"填写密码位数过少"];
        return;
    }
    
    _isNeedRereshAuth = YES;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:_phoneTextField.text forKey:@"phone2"];
    [user setObject:_passwordTextField.text forKey:@"password2"];
    [user synchronize];
    
    
    NSString *phone = [_phoneTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *password = [_passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *auth = [_authTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    VipWebViewController *vipWebView = [[VipWebViewController alloc] init];
    vipWebView.num = @"12345678";
    vipWebView.phone = phone;
    vipWebView.password = password;
    vipWebView.authString = auth;
    vipWebView.isFromCache = YES;
    [self presentViewController:vipWebView animated:YES completion:nil];
}

- (IBAction)changeAction:(id)sender {
    self.changeBtn.selected = !self.changeBtn.selected;
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if (self.changeBtn.selected) {
        //过滤
        [user setObject:[self.inputTextView.text mutableCopy] forKey:@"inputTextView"];
        self.inputTextView.text = [user objectForKey:@"inputTextView1"];
        
    }else{
        //正常
        [user setObject:[self.inputTextView.text mutableCopy] forKey:@"inputTextView1"];
        self.inputTextView.text = [user objectForKey:@"inputTextView"];

    }
}

- (IBAction)nextAction:(id)sender {
    QYHNextViewController *nextVC = [[QYHNextViewController alloc] initWithNibName:@"QYHNextViewController" bundle:nil];
    nextVC.isSecond = YES;
    [self presentViewController:nextVC animated:YES completion:nil];
}


- (IBAction)startAction:(id)sender {
    
    self.startActionBtn.selected = !self.startActionBtn.selected;
    
    if (self.startActionBtn.selected) {
        _isStop = NO;
        _qiangGouCount = 0;
        [self getAuthCode];
        
    }else{
        _isStop = YES;
        
    }
}

@end
