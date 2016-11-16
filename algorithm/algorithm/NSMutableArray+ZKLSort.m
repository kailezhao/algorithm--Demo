//
//  NSMutableArray+Algorithm.m
//  algorithm
//
//  Created by WT－WD on 16/11/16.
//  Copyright © 2016年 WT－WD. All rights reserved.
//

#import "NSMutableArray+ZKLSort.h"

@implementation NSMutableArray (ZKLSort)
//交换两个元素
-(void)zkl_exchangeWithIndexA:(NSInteger)indexA indexB:(NSInteger)indexB didExcahnge:(sortExchangeCallback)exchangeCallback{
    
    id temp = self[indexA];
    self[indexA] = self[indexB];
    self[indexB] = temp;
    
    if (exchangeCallback) {
        exchangeCallback(temp,self[indexA]);
    }
    
}
    
    
#pragma mark - 选择排序
-(void)zkl_selectionSortComparator:(sortComparator)comparator
                      didExchange :(sortExchangeCallback)exchangeCallback{
    if (self.count==0) {
        return;
    }
    
    for (int i = 0; i<self.count - 1; i++) {
        for (int j = i+1 ; j<self.count; j++) {
            if (comparator(self[i],self[j]) ==NSOrderedDescending ) {
                [self zkl_exchangeWithIndexA:i indexB:j didExcahnge:exchangeCallback];
            }
        }
    }
}
#pragma mark - 冒泡排序
-(void)zkl_bubblingSortComparator:(sortComparator)comparator
                      didExchange:(sortExchangeCallback)exchangeCallback{
    if (self.count==0) {
        return;
    }
    
    for (int i = (int)self.count-1; i > 0; i--) {
        for (int j = 0; j < i ; j++) {
            if (comparator(self[j],self[j+1]) == NSOrderedDescending) {
                [self zkl_exchangeWithIndexA:j indexB:j+1 didExcahnge:exchangeCallback];
            }
        }
    }
    
}
    
#pragma mark - 插入排序
-(void)zkl_insertSortComparator:(sortComparator)comparator
                    didExcahnge:(sortExchangeCallback)exchangeCallback{
    if(self.count == 0){
        return;
    }
    
    for (int i = 1; i<self.count; i++) {
        for (int j = i; j > 0 && comparator(self[j],self[j-1]) == NSOrderedAscending; j--) {
            [self zkl_exchangeWithIndexA:j indexB:j-1 didExcahnge:exchangeCallback];
        }
    }
    
}
 
#pragma mark - 快速排序
-(void)zkl_fastSortComparator:(sortComparator)comparator
                  didExchange:(sortExchangeCallback)exchangeCallback{
    if (self.count==0) {
        return;
    }
    
    [self quickSortWithLowIndex:0 hightIndex:self.count-1 comparator:comparator didExchange:exchangeCallback];
}
-(void)quickSortWithLowIndex:(NSInteger)low hightIndex:(NSInteger)high comparator:(sortComparator)comparator didExchange:(sortExchangeCallback)exchangeCallback{
    if (low >= high) {
        return;
    }
    
   NSInteger pivotIndex = [self quickPartitionWithLowIndex:low
                                                 highIndex:high
                                                comparator:comparator
                                               didExchange:exchangeCallback];
    
    [self quickSortWithLowIndex:low
                     hightIndex:pivotIndex-1
                     comparator:comparator
                    didExchange:exchangeCallback];
    
    [self quickSortWithLowIndex:pivotIndex + 1
                     hightIndex:high
                     comparator:comparator
                    didExchange:exchangeCallback];
    
}
    
-(NSInteger)quickPartitionWithLowIndex:(NSInteger)low
                             highIndex:(NSInteger)high
                            comparator:(sortComparator)comparaotr
                           didExchange:(sortExchangeCallback)exchangeCallback{
    id pivot = self[low];
    NSInteger i = low;
    NSInteger j = high;
    
    while (i < j) {
        //略过大于等于pivot的元素
        while (i < j && comparaotr(self[j],pivot) != NSOrderedAscending) {
            j--;
        }if (i < j) {
            //i、j未相遇，说明找到了小于pivot的元素，交换
            [self zkl_exchangeWithIndexA:i
                                  indexB:j
                             didExcahnge:exchangeCallback];
            i++;
        }
        //略过小于等于pivot的元素
        while (i < j && comparaotr(self[i],pivot) != NSOrderedDescending) {
            i++;
        }
        if (i < j) {
            //i、j未相遇，说明找到了大约pivot的元素，交换
            [self zkl_exchangeWithIndexA:i indexB:j didExcahnge:exchangeCallback];
            j--;
        }
    }
    
    return i;
}
    
#pragma mark - 堆排序
-(void)zkl_heapSortComparator:(sortComparator)comparator
                  didExchange:(sortExchangeCallback)exchangeCallback{
    // 排序过程中不使用第0位
    [self insertObject:[NSNull null] atIndex:0];
    
    // 构造大顶堆
    // 遍历所有非终结点，把以它们为根结点的子树调整成大顶堆
    // 最后一个非终结点位置在本队列长度的一半处
    for (int i = (int)self.count/2 ; i > 0 ; i--) {
        // 根结点下沉到合适位置
        [self sinkIndex:i
            bottomIndex:self.count-1
             comparator:comparator
            didExchange:exchangeCallback];
    }
    
    // 完全排序
    // 从整棵二叉树开始，逐渐剪枝
    for (int i = (int)self.count-1; i>1; i--) {
        // 每次把根结点放在列尾，下一次循环时将会剪掉
        [self zkl_exchangeWithIndexA:1 indexB:i didExcahnge:exchangeCallback];
         // 下沉根结点，重新调整为大顶堆
        [self sinkIndex:1 bottomIndex:i-1 comparator:comparator didExchange:exchangeCallback];
        
    }
    // 排序完成后删除占位元素
    [self removeObjectAtIndex:0];

}
/// 下沉，传入需要下沉的元素位置，以及允许下沉的最底位置
-(void)sinkIndex:(NSInteger)index
     bottomIndex:(NSInteger)bottomIndex
      comparator:(sortComparator)comparator
     didExchange:(sortExchangeCallback)exchangeCallback{
    for (int maxChildIndex = (int)index*2; maxChildIndex <= bottomIndex; maxChildIndex *= 2) {
        // 如果存在右子结点，并且左子结点比右子结点小
        if (maxChildIndex < bottomIndex && (comparator(self[maxChildIndex],self[maxChildIndex+1]) == NSOrderedAscending)) {
            // 指向右子结点
            ++maxChildIndex;
        }
        // 如果最大的子结点元素小于本元素，则本元素不必下沉了
        if (comparator(self[maxChildIndex],self[index]) == NSOrderedAscending) {
            break;
        }
        // 否则
        // 把最大子结点元素上游到本元素位置
        [self zkl_exchangeWithIndexA:index indexB:maxChildIndex didExcahnge:exchangeCallback];
         // 标记本元素需要下沉的目标位置，为最大子结点原位置
        index= maxChildIndex;
        
    }
}
    
    
    
@end
