//
//  Guess.m
//  Guess
//
//  Created by 何苗 on 2018/3/9.
//  Copyright © 2018年 joehe. All rights reserved.
//

#import "Guess.h"

@interface Guess () {
    // 问题列表
    NSArray* _questions;
}
@end

@implementation Guess

-(id)init {
    self = [super init];
    if (self) {
        // 设置当前问题 index 为 第一项
        self.currentIndex = 0;
        // 初始化 问题列表
        [self _initQuestions];
    }
    return self;
}

-(IdiomModel*)getCurrentModel {
    IdiomModel* model = _questions[self.currentIndex];
    
    // 重置 answerIndexArr
    int len = (int)model.answer.length;
    // 创建可变数组
    NSMutableArray* mutArr = [NSMutableArray array];
    for (int i = 0; i < len; i++) {
        [mutArr addObject: [NSString stringWithFormat: @"%d", -1]];
    }
    self.answerIndexArr = mutArr;
    
    return model;
}

-(int)getQuestionsCount {
    return (int)_questions.count;
}

// 判断数组是否已经全部填充（没有 -1）
-(BOOL)checkEnd {
    BOOL isEnd = true;
    for (int i = 0, len = (int)self.answerIndexArr.count; i < len; i++) {
        NSString* item = [self.answerIndexArr objectAtIndex:i];
        if (item.intValue == -1) {
            isEnd = false;
            break;
        }
    }
    return isEnd;
}

-(void)setAnswerArr:(int)index {
    for (int i = 0, len = (int)self.answerIndexArr.count; i < len; i++) {
        NSString* item = [self.answerIndexArr objectAtIndex:i];
        if (item.intValue == -1) {
            [self.answerIndexArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat: @"%d", index]];
            // 通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFINDEX" object:[NSNumber numberWithInt:i]];
            break;
        }
    }
    
    // 判断数组是否已经全部填充（没有 -1）
    // 判断答案是否正确
    if ([self checkEnd]) {
        IdiomModel* model = _questions[self.currentIndex];
        NSMutableString* answerStr = [[NSMutableString alloc] init];
        for (NSString* item in self.answerIndexArr) {
            [answerStr appendString:model.options[item.intValue]];
        }
        NSString* ans = answerStr;
        if ([ans isEqualToString:model.answer]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFISOK" object:[NSNumber numberWithInt:1]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFISOK" object:[NSNumber numberWithInt:0]];
        }
    }
}

-(int) resetAnswerArr:(int)index {
    NSString* item = [self.answerIndexArr objectAtIndex:index];
    [self.answerIndexArr replaceObjectAtIndex:index withObject:[NSString stringWithFormat: @"%d", -1]];
    return item.intValue;
}

/* 私有方法 */
-(void) _initQuestions {
    // 获取 questions.plist 路径
    NSString* path = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"plist"];
    // 保存从 plist 字典
    NSArray* dictArr = [NSArray arrayWithContentsOfFile:path];
    
    // 创建可变数组，循环赋值到 IdiomModel
    NSMutableArray* mutArr = [NSMutableArray array];
    for (NSDictionary *dict in dictArr) {
        IdiomModel* model = [[IdiomModel alloc] init];
        model.answer = dict[@"answer"];
        model.title = dict[@"title"];
        model.options = dict[@"options"];
        
        [mutArr addObject:model];
    }
    // 赋值给私有属性 _questions
    _questions = mutArr;
}

@end
