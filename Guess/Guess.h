//
//  Guess.h
//  Guess
//
//  Created by 何苗 on 2018/3/9.
//  Copyright © 2018年 joehe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IdiomModel.h"

@interface Guess : NSObject

@property(nonatomic, assign) int currentIndex; // 当前问题 index
@property(nonatomic, strong) NSMutableArray* answerIndexArr; // 在选项中选择的答案字符序号数组

-(IdiomModel*) getCurrentModel;
-(int) getQuestionsCount;
// 判断数组是否已经全部填充（没有 -1）
-(BOOL) checkEnd;
-(void) setAnswerArr:(int)index;
-(int) resetAnswerArr:(int)index;
@end
