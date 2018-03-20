//
//  ViewController.m
//  Guess
//
//  Created by 何苗 on 2018/3/9.
//  Copyright © 2018年 joehe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    int _score;
    Guess* _guess;
    IdiomModel* _currentModel;
    
    // 答案区的按钮数组
    NSArray* _answerBtnArr;
    // 选项区的按钮数组
    NSArray* _optionBtnArr;
}

@property (weak, nonatomic) IBOutlet UILabel *currentIndexAndCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *currentImageBtn;
@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *optionView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

- (IBAction)changeSizeBtnClick;
- (IBAction)imageBtnClick:(UIButton *)sender;

- (IBAction)nextBtnClick;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 通知中心
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectOption:) name:@"NOTIFINDEX" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(answerIsOk:) name:@"NOTIFISOK" object:nil];
    
    _score = 0;
    _guess = [[Guess alloc] init];
    _currentModel = [_guess getCurrentModel];
    
    [self setScore:10000];
    
    // currentImageBtn 的边框
    self.currentImageBtn.layer.borderWidth = 5.0;
    self.currentImageBtn.layer.borderColor = [UIColor cyanColor].CGColor;
    
    // 取消点击 currentImageBtn 闪烁
    [self.currentImageBtn addTarget:self action:@selector(preventFlicker:) forControlEvents:UIControlEventAllTouchEvents];

    [self updateView];
}

-(void)setScore:(int)score {
    _score += score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
}

-(void)updateView {
    // n/m Label
    int _index = _guess.currentIndex + 1;
    int _count = [_guess getQuestionsCount];
    self.currentIndexAndCountLabel.text = [NSString stringWithFormat:@"%d/%d",_index, _count];
    
    // title Label
    self.titleLabel.text = _currentModel.title;
    
    // currentImageBtn
    [self.currentImageBtn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", _guess.currentIndex]] forState:UIControlStateNormal];
    
    // 答案区的按钮数组
    [self updateAnswerBtns];
    
    // 选项区的按钮数组
    [self updateOptionBtns];
}

-(void)updateAnswerBtns {
    float btn_w_h = 46.0; // 按钮的宽高
    float btn_margin = 10.0; // 按钮之间的间距
    // 1 清空以前的
    for (UIButton* btn in _answerBtnArr) {
        [btn removeFromSuperview];
    }
    
    // 2 构建
    int len = (int)_currentModel.answer.length; // 按钮数量
    float _btns_width = (btn_w_h + btn_margin) * len - btn_margin; // 按钮组所占的宽度
    float left_margin = (self.view.frame.size.width - _btns_width) / 2;
    
    // 创建可变数组，循环创建 btn
    NSMutableArray* mutArr = [NSMutableArray array];
    for (int i = 0; i < len; i++) {
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(left_margin + i * (btn_w_h + btn_margin), 2, btn_w_h, btn_w_h)];

        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        
        btn.tag = i;
        
        [btn addTarget:self action:@selector(answerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.answerView addSubview:btn];
        
        [mutArr addObject:btn];
    }
    // 赋值给私有属性 _answerBtnArr
    _answerBtnArr = mutArr;
}

-(void)updateOptionBtns {
    float btn_w_h = 46.0; // 按钮的宽高
    float left_margin = (self.view.frame.size.width - btn_w_h * 7) / 8; // 按钮之间的间距
    
    // 1 清空以前的
    for (UIButton* btn in _optionBtnArr) {
        [btn removeFromSuperview];
    }
    
    // 2 构建
    // 创建可变数组，循环创建 btn
    NSMutableArray* mutArr = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 7; j++) {
            UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(left_margin + j * (btn_w_h + left_margin), left_margin + i * (btn_w_h + left_margin), btn_w_h, btn_w_h)];
            
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
            
            btn.tag = j + i * 7;
            
            [btn setTitle:_currentModel.options[j + i * 7] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [btn addTarget:self action:@selector(optionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.optionView addSubview:btn];
            
            [mutArr addObject:btn];
        }
    }
    // 赋值给私有属性 _optionBtnArr
    _optionBtnArr = mutArr;
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

-(void) changeSize {
    [UIView animateWithDuration:1.0f animations:^{
        if (self.currentImageBtn.frame.size.width == 180.0) {
            self.currentImageBtn.frame = CGRectMake(0, 172, 375, 375);
        } else if (self.currentImageBtn.frame.size.width == 375.0) {
            self.currentImageBtn.frame = CGRectMake(97, 136, 180, 180);
        }
    }];
}

- (IBAction)changeSizeBtnClick {
    [self changeSize];
}

- (IBAction)imageBtnClick:(UIButton *)sender {
    [self changeSize];
}

- (void)preventFlicker:(UIButton *)sender {
    sender.highlighted = NO;
}

- (IBAction)nextBtnClick {
    [self next];
}

-(void)next {
    int _index = _guess.currentIndex + 1;
    int _count = [_guess getQuestionsCount];
    // 判断是不是最后一题
    if (_index < _count) {
        _guess.currentIndex = _index;
        _currentModel = [_guess getCurrentModel];
        [self updateView];
    }
}

-(void)answerBtnClick:(UIButton *)sender {
    if (sender.currentTitle && ![sender.currentTitle isEqualToString:@""]) {
        [sender setTitle:@"" forState:UIControlStateNormal];
        int index = (int)sender.tag;
        int i = [_guess resetAnswerArr:index];
        UIButton* btn = _optionBtnArr[i];
        
        [btn setTitle:_currentModel.options[i] forState:UIControlStateNormal];
        btn.alpha = 1.0;
    }
}

-(void)optionBtnClick:(UIButton *)sender {
    if (![_guess checkEnd] && ![sender.currentTitle isEqualToString:@""]) {
        [sender setTitle:@"" forState:UIControlStateNormal];
        sender.alpha = 0.0;
        
        int index = (int)sender.tag;
        [_guess setAnswerArr:index];
    }
}

// NOTIFINDEX 通知回调
-(void)selectOption:(NSNotification *)notif {
    int i = [notif.object intValue];
    NSString* item = [_guess.answerIndexArr objectAtIndex:i];
    NSString* title = _currentModel.options[item.intValue];
    
    UIButton* btn = _answerBtnArr[i];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

-(void)answerIsOk:(NSNotification *)notif {
    NSString* message = @"恭喜你答错了";
    NSString* actionTitle = @"再来一次";
    int i = [notif.object intValue];
    if (i == 1) {
       [self setScore:10000];
        
        message = @"恭喜你答对了";
        actionTitle = @"点击取消";
        [self next];
    } else {
        [self setScore:-1000];
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NOTIFINDEX" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NOTIFISOK" object:nil];
}

@end
