//
//  IdiomModel.h
//  Guess
//
//  Created by 何苗 on 2018/3/9.
//  Copyright © 2018年 joehe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IdiomModel : NSObject

@property(nonatomic, copy) NSString* answer; // 答案
@property(nonatomic, copy) NSString* title; // 提示
@property(nonatomic, strong) NSArray* options; // 选项数组

@end
