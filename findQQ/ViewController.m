//
//  ViewController.m
//  findQQ
//
//  Created by 邱永槐 on 2017/3/14.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "QYHProgressHUD.h"
#import "QYHKeyBoardManagerViewController.h"
#import "QYHNextViewController.h"
#import "Userinfo.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *startTextField;

@property (weak, nonatomic) IBOutlet UITextField *endtextField;

@property (nonatomic,strong) NSMutableArray *arrM;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;


@property (nonatomic,assign) NSInteger count;

@property (weak, nonatomic) IBOutlet UITextField *uinTextField;
@property (weak, nonatomic) IBOutlet UITextField *skeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *itknTextField;
@property (weak, nonatomic) IBOutlet UITextField *ldwTextField;

@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;

@property (nonatomic,copy) NSString *start;
@property (nonatomic,copy) NSString *end;

@property (nonatomic,assign) NSInteger index;

@property (weak, nonatomic) IBOutlet UILabel *currentQQ;

@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic,assign) BOOL isEnd;

@property (nonatomic,strong) UIView *bgView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UILabel *zhiLabel;

@property (nonatomic,assign) NSInteger selectedSegmentIndex;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger searchIndex;


@property (nonatomic,assign) NSInteger skeyIndex;

@property (weak, nonatomic) IBOutlet UILabel *currentQLabel;

@property (nonatomic,copy) NSString *currentQString;

@property (weak, nonatomic) IBOutlet UIButton *nextQQBtn;
@property (weak, nonatomic) IBOutlet UIButton *prevQQBtn;

@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;

@end

@implementation ViewController

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
    // Do any additional setup after loading the view, typically from a nib.
    
    _arrM = [NSMutableArray array];
    _dataArray = [NSMutableArray array];
    
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    
//    _uinTextField.text = [user objectForKey:@"uin"];
//    _skeyTextField.text = [user objectForKey:@"skey"];
//    _itknTextField.text = [user objectForKey:@"itkn"];
//    _ldwTextField.text = [user objectForKey:@"ldw"];
    
    //v88jf4  ZZdV57 liangp lingp  SJHP
    
    self.startButton.layer.cornerRadius = 5;
    self.startButton.clipsToBounds = YES;
    
    [self.segmentedControl addTarget:self action:@selector(searchChange:) forControlEvents:UIControlEventValueChanged];
    _selectedSegmentIndex = 0;
    
    _skeyIndex = 0;
    Userinfo *userInfo = [Userinfo shareInstance];
    
    //[{skey2:value,uin2:value}]
    NSDictionary *dic = userInfo.skeyArray[_skeyIndex];
    
    self.uinTextField.text = [dic objectForKey:@"uin2"];
    self.skeyTextField.text = [dic objectForKey:@"skey2"];;
    self.ldwTextField.text = [self getLdw:[dic objectForKey:@"skey2"]];
    
    self.currentQLabel.text = [NSString stringWithFormat:@"正在使用qq:%@   总:%ld/%ld",[self.uinTextField.text substringFromIndex:1],(_skeyIndex + 1),userInfo.skeyArray.count];
    
    self.nextQQBtn.enabled = NO;
    self.prevQQBtn.enabled = NO;
}


- (NSString *)getLdw:(NSString *)str{
    
    NSInteger thash = 5381;
    for (int i = 0; i < str.length; i++) {
        NSInteger asciiCode =  [str characterAtIndex:i];
        NSInteger lhash = thash << 5;
        thash += lhash + asciiCode;
    }
    
    thash = thash & 2147483647;
    
    return [NSString stringWithFormat:@"%ld",thash];
}

-(void)searchChange:(UISegmentedControl *)sender{
    
    _selectedSegmentIndex = sender.selectedSegmentIndex;
    
    self.selectedBtn.hidden = sender.selectedSegmentIndex == 1 ? YES : NO;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [QYHKeyBoardManagerViewController shareInstance].selfView = self.view;
    
    [self.view bringSubviewToFront:self.bgView];
    [self.view bringSubviewToFront:self.startButton];
    
}



- (IBAction)selAction:(UIButton *)sender {
    
    self.selectedBtn.selected = !self.selectedBtn.selected;
    
}


- (IBAction)start:(id)sender {
    
    if ([self isError]) {
        return;
    }
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        
        Userinfo *userInfo = [Userinfo shareInstance];
        
        if (_skeyIndex >= userInfo.skeyArray.count - 1) {
            self.nextQQBtn.enabled = NO;
        }else{
            self.nextQQBtn.enabled = YES;
        }
        
        //开始
        self.bgView.hidden = NO;
        
        _isEnd = NO;
        _count = 0;
        [_arrM removeAllObjects];
        self.resultTextView.text = nil;
        [self.view endEditing:YES];
        
        if (_selectedSegmentIndex == 0) {
            //正常搜索
            
            [self getPreData];
           
            NSString *keyNumber = _startTextField.text;
            [self findQQ:keyNumber];
            
        }else{
            //9、10位搜索
            
            [self getJiuShiWeiData];
            
            NSString *keyNumber = [_dataArray firstObject];
            [self findQQ:keyNumber];
        }
        
    }else{
        //终止
        _isEnd = YES;
        [_manager.operationQueue cancelAllOperations];
        self.bgView.hidden = YES;
    }
}


- (IBAction)getDataAction:(id)sender {
    
    if ([self isError]) {
        return;
    }

    [QYHProgressHUD showHUDAddedTo:self.view animated:YES];
    self.resultTextView.text = nil;
    [self.view endEditing:YES];
    
    if (_selectedSegmentIndex == 0) {
        //正常搜索
        [self getPreData];
        
        [_dataArray removeAllObjects];
        
        if (self.selectedBtn.selected) {
            for (NSInteger i = [self.start integerValue]; i <= [self.end integerValue]; i++) {
                self.start = [NSString stringWithFormat:@"%ld",i];
                NSString *keyNumber = [self.start stringByAppendingString:[self.startTextField.text substringFromIndex:self.index]];
                [_dataArray addObject:keyNumber];
            }
        }else{
             for (NSInteger i = [self.startTextField.text integerValue]; i <= [self.endtextField.text integerValue]; i++) {

                 [_dataArray addObject:[NSString stringWithFormat:@"%ld",i]];
             }
        }
        
    }else{
        //9、10位搜索
        [self getJiuShiWeiData];

    }
    
    NSLog(@"getDataAction_dataArray==%ld",_dataArray.count);
    
    self.resultTextView.text = [_dataArray componentsJoinedByString:@","];
    
    [QYHProgressHUD hideHUDForView:self.view animated:YES];
}



//从前面变化的
- (void)getPreData{
    
    if (self.selectedBtn.selected) {
        
        for (NSInteger i = self.startTextField.text.length - 1; i>=0; i--) {
            NSString *starString = [self.startTextField.text substringWithRange:NSMakeRange(i, 1)];
            NSString *endString = [self.endtextField.text substringWithRange:NSMakeRange(i, 1)];
            
            if (![starString isEqualToString:endString]) {
                self.index = i + 1;
                break;
            }
        }
        
        self.start = [self.startTextField.text substringToIndex:self.index];
        self.end = [self.endtextField.text substringToIndex:self.index];
        
    }
}

//判断输入是否正确
- (BOOL)isError{
    
//    if (_uinTextField.text.length < 1 || _skeyTextField.text.length < 1|| _itknTextField.text.length < 1|| _ldwTextField.text.length < 1) {
//        [QYHProgressHUD showErrorHUD:nil message:@"请填写参数"];
//        return YES;
//    }
    
    if (_startTextField.text.length < 1) {
        [QYHProgressHUD showErrorHUD:nil message:@"请填写号码"];
        return YES;
    }
    
    if (_endtextField.text.length < 1) {
        [QYHProgressHUD showErrorHUD:nil message:@"请填写号码"];
        return YES;
    }
    
    if ([_startTextField.text integerValue] > [_endtextField.text integerValue]) {
        [QYHProgressHUD showErrorHUD:nil message:@"填写号码顺序不正确"];
        return YES;
    }
    
    if (_selectedSegmentIndex == 1) {
        if (_startTextField.text.length != 3 || _endtextField.text.length != 3) {
            [QYHProgressHUD showErrorHUD:nil message:@"请输入3位数字"];
            return YES;
        }
    }else if (_selectedSegmentIndex == 2) {
        if (_startTextField.text.length != 10 || _endtextField.text.length != 10) {
            [QYHProgressHUD showErrorHUD:nil message:@"请输入10位数字"];
            return YES;
        }
        
        if (self.selectedBtn.selected) {
            
        }else{
            if ([_startTextField.text integerValue] + 100000000 < [_endtextField.text integerValue]) {
                [QYHProgressHUD showErrorHUD:nil message:@"输入区间过大！"];
                return YES;
            }
        }
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [user setObject:_uinTextField.text forKey:@"uin"];
    [user setObject:_skeyTextField.text forKey:@"skey"];
    [user setObject:_itknTextField.text forKey:@"itkn"];
    [user setObject:_ldwTextField.text forKey:@"ldw"];
    [user synchronize];
    
    return NO;
}

//9、10位数据
- (void)getJiuShiWeiData{
    
    [_dataArray removeAllObjects];
    _searchIndex = 0;
    
    if (_selectedSegmentIndex == 1) {
        //9位搜索
        //100101102
        
        for (NSInteger i = [_startTextField.text integerValue];i<=[_endtextField.text integerValue];i +=1) {
            
            
            for (int j = 0; j<3; j++) {
                
                NSInteger one1   = i;
                NSInteger two1   = i + 1 * pow(10, j);
                NSInteger three1 = i + 2 * pow(10, j);
                
                NSInteger yushu1 = i % 10;
                
                if (j==1) {
                    yushu1 = (i/10)%10;
                }else if (j==2){
                    yushu1 = i/100;
                }
                
                if (yushu1 <= 7) {
                    NSString *number = [NSString stringWithFormat:@"%ld%ld%ld",one1,two1,three1];
                    [_dataArray addObject:number];
                }
                
                NSInteger one2   = i;
                NSInteger two2   = i - 1 * pow(10, j);
                NSInteger three2 = i - 2 * pow(10, j);
                
                if (yushu1 >= 2) {
                    NSString *number = [NSString stringWithFormat:@"%03ld%03ld%03ld",one2,two2,three2];
                    [_dataArray addObject:number];
                }
            }
        }
        
    }else if (_selectedSegmentIndex == 2){
        //10位搜索
        //1000010000

        if (self.selectedBtn.selected) {
            
            NSString *startString = [self.startTextField.text substringToIndex:5];
            NSString *endString = [self.endtextField.text substringToIndex:5];
            NSInteger index = 0;
            
            for (NSInteger i = 4; i>=0; i--) {
                NSString *start = [startString substringWithRange:NSMakeRange(i, 1)];
                NSString *end = [endString substringWithRange:NSMakeRange(i, 1)];
                
                if (![start isEqualToString:end]) {
                    index = i;
                    break;
                }
            }

            NSInteger num = 100001;
            switch (index) {
                case 0:
                    num = 1000010000;
                    break;
                case 1:
                    num = 100001000;
                    break;
                case 2:
                    num = 10000100;
                    break;
                case 3:
                    num = 1000010;
                    break;
                case 4:
                    num = 100001;
                    break;
                default:
                    break;
            }
            
            for (NSInteger i = [_startTextField.text integerValue]; i<=[_endtextField.text integerValue];i += num) {
                
                [_dataArray addObject:[NSString stringWithFormat:@"%ld",i]];
            }
            
        }else{
            for (NSInteger i = [_startTextField.text integerValue]; i<=[_endtextField.text integerValue];i +=100001) {
                
                [_dataArray addObject:[NSString stringWithFormat:@"%ld",i]];
            }
        }
    }
    
    NSLog(@"_dataArray11111==%@,count==%ld",_dataArray,_dataArray.count);
}




- (void)findQQ:(NSString *)qq{
    
    self.currentQQ.text = [NSString stringWithFormat:@"搜索到QQ号：%@",qq];
    
    self.currentQString = qq;
    
    NSDictionary *parameters = @{@"num":@"20",
                                 @"page":@"0",
                                 @"sessionid":@"0",
                                 @"keyword":qq,
                                 @"agerg":@"0",
                                 @"sex":@"0",
                                 @"firston":@"0",
                                 @"video":@"0",
                                 @"country":@"0",
                                 @"province":@"0",
                                 @"city":@"0",
                                 @"district":@"0",
                                 @"hcountry":@"0",
                                 @"hprovince":@"0",
                                 @"hcity":@"0",
                                 @"hdistrict":@"0",
                                 @"online":@"0",
                                 @"ldw":self.ldwTextField.text
                                 };
    
    _manager = [AFHTTPRequestOperationManager manager];
    
    [_manager.requestSerializer setValue:[NSString stringWithFormat: @"uin=%@;skey=%@",self.uinTextField.text,self.skeyTextField.text] forHTTPHeaderField:@"Cookie"];
    
    [_manager POST:@"http://cgi.find.qq.com/qqfind/buddy/search_v3" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject==%@",responseObject);
       
        BOOL successe = NO;
        
        if ([[responseObject objectForKey:@"retcode"] integerValue] == 0) {
            successe = YES;
            
            NSDictionary *result = [responseObject objectForKey:@"result"];
            
            if (result) {
                NSDictionary *buddy = [result objectForKey:@"buddy"];
                if (buddy) {
                    NSArray *info_list = [buddy objectForKey:@"info_list"];
                    
                    if (!info_list) {
                        [_arrM addObject:qq];
                    }
                    
                }else{
                    [_arrM addObject:qq];
                }
            }
            
        }
//        else if ([[responseObject objectForKey:@"retcode"] integerValue] == 6){
//            successe = NO;
//            
////            NSLog(@"retcode=6的qq：%@",[NSString stringWithFormat:@"%@",qq]);
////            successe = YES;
////            [_arrM addObject:qq];
//            
//            _skeyIndex++;
//            Userinfo *userInfo = [Userinfo shareInstance];
//            
//            if (_skeyIndex < userInfo.skeyArray.count) {
//                
//                [QYHProgressHUD showErrorHUD:nil message:@"正在换号码！！！"];
//                
//                //[{skey2:value,uin2:value}]
//                NSDictionary *dic = userInfo.skeyArray[_skeyIndex];
//                
//                self.uinTextField.text = [dic objectForKey:@"uin2"];
//                self.skeyTextField.text = [dic objectForKey:@"skey2"];;
//                self.ldwTextField.text = [self getLdw:[dic objectForKey:@"skey2"]];
//                
//                self.currentQLabel.text = [NSString stringWithFormat:@"正在使用qq:%@   总:%ld/%ld",[self.uinTextField.text substringFromIndex:1],(_skeyIndex + 1),userInfo.skeyArray.count];
//                
//                [self findQQ:qq];
//                
//            }else{
//                [QYHProgressHUD showErrorHUD:nil message:@"号码已经用完，请登陆更多的qq号码再重新查询!"];
//                self.startButton.selected = !self.startButton.selected;
//                self.resultTextView.text = [_arrM componentsJoinedByString:@","];
//                
//                self.bgView.hidden = YES;
//                
//                if (!self.selectedSegmentIndex) {
//                    self.startTextField.text = qq;
//                }
//            }
//          
//        }
        
        else{
            successe = NO;
            _count++;
            
          
//            if (_count != 3 && _count != 10) {
//                   [QYHProgressHUD showErrorHUD:nil message:[NSString stringWithFormat:@"查询中出现错误 retcode==%@，，继续重试%ld次查找",[responseObject objectForKey:@"retcode"],(long)_count]];
//            }
//         
            
//            if (_count == 3) {
//                _skeyIndex++;
//                Userinfo *userInfo = [Userinfo shareInstance];
//                
//                if (_skeyIndex < userInfo.skeyArray.count) {
//                    
//                    [QYHProgressHUD showErrorHUD:nil message:@"正在换号码！！！"];
//                    
//                    //[{skey2:value,uin2:value}]
//                    NSDictionary *dic = userInfo.skeyArray[_skeyIndex];
//                    
//                    self.uinTextField.text = [dic objectForKey:@"uin2"];
//                    self.skeyTextField.text = [dic objectForKey:@"skey2"];;
//                    self.ldwTextField.text = [self getLdw:[dic objectForKey:@"skey2"]];
//                  
//                    self.currentQLabel.text = [NSString stringWithFormat:@"正在使用qq:%@   总:%ld/%ld",[self.uinTextField.text substringFromIndex:1],(_skeyIndex + 1),userInfo.skeyArray.count];
//                    
//                }else{
//                     [QYHProgressHUD showErrorHUD:nil message:[NSString stringWithFormat:@"查询中出现错误 retcode==%@，，继续重试%ld次查找",[responseObject objectForKey:@"retcode"],(long)_count]];
//                }
//            }
            
            if (_count == 5) {
                 [QYHProgressHUD showErrorHUD:nil message:@"次数已用完，请切换号码！"];
                self.startButton.selected = NO;
                self.resultTextView.text = [_arrM componentsJoinedByString:@","];

                self.bgView.hidden = YES;
                
                if (!self.selectedSegmentIndex) {
                    self.startTextField.text = qq;
                }
                
            }else{
                
                 [QYHProgressHUD showErrorHUD:nil message:[NSString stringWithFormat:@"查询中出现错误 retcode==%@，，继续重试%ld次查找",[responseObject objectForKey:@"retcode"],(long)_count]];
                [self findQQ:qq];
            }
        }
        
        if (successe) {
            _count = 0;
            BOOL isLasted = NO;
            
            if (_selectedSegmentIndex) {
                if (_searchIndex == _dataArray.count - 1) {
                    isLasted = YES;
                }
            }else{
                if ([qq isEqualToString:_endtextField.text]) {
                    isLasted = YES;
                }
            }
            
            if (isLasted) {
                self.bgView.hidden = YES;
                [QYHProgressHUD showSuccessHUD:nil message:@"查询完毕"];
                self.startButton.selected = NO;
            }else{
                if (_selectedSegmentIndex) {
                    _searchIndex++;
                    [self findQQByDataArray];
                }else{
                    [self findQ:qq];
                }
            }
            
            self.resultTextView.text = [_arrM componentsJoinedByString:@","];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //失败走失败的回调
        NSLog(@"error==%@",error);
        [QYHProgressHUD showErrorHUD:nil message:error.code != -999 ? @"查询中出现错误":@"取消查询"];
        self.startButton.selected = NO;
        self.resultTextView.text = [_arrM componentsJoinedByString:@","];

        self.bgView.hidden = YES;
        if (!self.selectedSegmentIndex && error.code != -999) {
            self.startTextField.text = qq;
        }
    }];
    
}

//9、10位搜索
- (void)findQQByDataArray{
    
    if (_isEnd) {
        return;
    }

    if (_searchIndex >= _dataArray.count) {
        return;
    }
    
    NSString *keyNumber = [_dataArray objectAtIndex:_searchIndex];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self findQQ:keyNumber];
    });
}

//输入搜索
- (void)findQ:(NSString *)qq{
    
    if (_isEnd) {
        return;
    }
    
    NSString *keyNumber;
    
    if (self.selectedBtn.selected) {
        //前面
         NSLog(@"self.start==%@",self.start);
        self.start = [NSString stringWithFormat:@"%ld",[self.start integerValue]+1];
        keyNumber = [self.start stringByAppendingString:[self.startTextField.text substringFromIndex:self.index]];
       
    }else{
        //后面
        
        keyNumber = [NSString stringWithFormat:@"%ld",[qq integerValue]+1];
        
    }
    
    
    if ([keyNumber integerValue] <= [_endtextField.text integerValue]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self findQQ:keyNumber];
        });
    }
    
}

- (IBAction)nextAction:(id)sender {
    
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if (_block) {
        _block(self.resultTextView.text);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
//    QYHNextViewController *nextVC = [[QYHNextViewController alloc] initWithNibName:@"QYHNextViewController" bundle:nil];
//    nextVC.dataString = self.resultTextView.text;
//    
//    [self presentViewController:nextVC animated:YES completion:nil];
}


-(void)setBlock:(GetText)block{
 
    _block = block;
}


- (IBAction)nextQQ:(id)sender {
    
    self.prevQQBtn.enabled = YES;
    _skeyIndex++;
    
    Userinfo *userInfo = [Userinfo shareInstance];
    
    if (_skeyIndex >= userInfo.skeyArray.count - 1) {
        self.nextQQBtn.enabled = NO;
    }

    
    if (_skeyIndex < userInfo.skeyArray.count) {
        
        [QYHProgressHUD showErrorHUD:nil message:@"正在换号码！！！"];
        
        //[{skey2:value,uin2:value}]
        NSDictionary *dic = userInfo.skeyArray[_skeyIndex];
        
        self.uinTextField.text = [dic objectForKey:@"uin2"];
        self.skeyTextField.text = [dic objectForKey:@"skey2"];;
        self.ldwTextField.text = [self getLdw:[dic objectForKey:@"skey2"]];
        
        self.currentQLabel.text = [NSString stringWithFormat:@"正在使用qq:%@   总:%ld/%ld",[self.uinTextField.text substringFromIndex:1],(_skeyIndex + 1),userInfo.skeyArray.count];
        
        self.startButton.selected = YES;
        self.bgView.hidden = NO;
        [self findQQ:self.currentQString];
        
        
    }else{
        [QYHProgressHUD showErrorHUD:nil message:@"号码已经用完，请登陆更多的qq号码再重新查询!"];
        self.startButton.selected = NO;
        self.resultTextView.text = [_arrM componentsJoinedByString:@","];
        
        self.bgView.hidden = YES;
        
    }

}

- (IBAction)prevQQ:(id)sender {
    
    _skeyIndex--;
    
    if (_skeyIndex == 0) {
        self.prevQQBtn.enabled = NO;
    }
    
     self.nextQQBtn.enabled = YES;
    
    Userinfo *userInfo = [Userinfo shareInstance];
    
    if (_skeyIndex < userInfo.skeyArray.count) {
        
        [QYHProgressHUD showErrorHUD:nil message:@"正在换号码！！！"];
        
        //[{skey2:value,uin2:value}]
        NSDictionary *dic = userInfo.skeyArray[_skeyIndex];
        
        self.uinTextField.text = [dic objectForKey:@"uin2"];
        self.skeyTextField.text = [dic objectForKey:@"skey2"];;
        self.ldwTextField.text = [self getLdw:[dic objectForKey:@"skey2"]];
        
        self.currentQLabel.text = [NSString stringWithFormat:@"正在使用qq:%@   总:%ld/%ld",[self.uinTextField.text substringFromIndex:1],(_skeyIndex + 1),userInfo.skeyArray.count];
        
        self.startButton.selected = YES;
        self.bgView.hidden = NO;
        [self findQQ:self.currentQString];
        
        
    }
    
}

@end
