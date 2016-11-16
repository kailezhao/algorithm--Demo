//
//  NSMutableArray+Algorithm.h
//  algorithm
//
//  Created by WT－WD on 16/11/16.
//  Copyright © 2016年 WT－WD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSComparisonResult(^sortComparator)(id obj1 , id obj2);
typedef void(^sortExchangeCallback)(id obj1 , id obj2);

@interface NSMutableArray (ZKLSort)

//选择排序
-(void)zkl_selectionSortComparator:(sortComparator)comparator
                       didExchange:(sortExchangeCallback)exchangeCallback;
    
    
//冒泡排序
-(void)zkl_bubblingSortComparator:(sortComparator)comparator
                      didExchange:(sortExchangeCallback)exchangeCallback;
//插入排序
-(void)zkl_insertSortComparator:(sortComparator)comparator
                    didExcahnge:(sortExchangeCallback)exchangeCallback;
    
//快速排序
-(void)zkl_fastSortComparator:(sortComparator)comparator
                  didExchange:(sortExchangeCallback)exchangeCallback;
    
//堆排序
-(void)zkl_heapSortComparator:(sortComparator)comparator
                  didExchange:(sortExchangeCallback)exchangeCallback;
    
@end
