//
//  UICollectionView+XD_Reorder.m
//  XDBookShelf
//
//  Created by 施孝达 on 16/4/5.
//  Copyright © 2016年 施孝达. All rights reserved.
//

#import "UICollectionView+XD_Reorder.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, XWDragCellCollectionViewScrollDirection) {
    XWDragCellCollectionViewScrollDirectionNone = 0,
    XWDragCellCollectionViewScrollDirectionLeft,
    XWDragCellCollectionViewScrollDirectionRight,
    XWDragCellCollectionViewScrollDirectionUp,
    XWDragCellCollectionViewScrollDirectionDown
};

@interface UICollectionView ()
@property (nonatomic, strong) NSIndexPath *originalIndexPath;
@property (nonatomic, strong) NSIndexPath *moveIndexPath;
@property (nonatomic, weak) UIView *tempMoveCell;
@property (nonatomic, strong) CADisplayLink *edgeTimer;
@property (nonatomic, assign) XWDragCellCollectionViewScrollDirection scrollDirection;
@end

@implementation UICollectionView (XD_Reorder)

- (UIView *)tempMoveCell {
    return objc_getAssociatedObject(self, @selector(tempMoveCell));
}

- (void)setTempMoveCell:(UIView *)tempMoveCell {
    objc_setAssociatedObject(self, @selector(tempMoveCell), tempMoveCell, OBJC_ASSOCIATION_ASSIGN);
}

- (XWDragCellCollectionViewScrollDirection)scrollDirection {
    return [objc_getAssociatedObject(self, @selector(scrollDirection)) integerValue];
}

- (void)setScrollDirection:(XWDragCellCollectionViewScrollDirection)scrollDirection {
    objc_setAssociatedObject(self, @selector(scrollDirection), @(scrollDirection), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)edgeScrollEable {
    return [objc_getAssociatedObject(self, @selector(edgeScrollEable)) boolValue];
}

- (void)setEdgeScrollEable:(BOOL)edgeScrollEable {
    objc_setAssociatedObject(self, @selector(edgeScrollEable), @(edgeScrollEable), OBJC_ASSOCIATION_ASSIGN);
}

- (NSIndexPath *)originalIndexPath {
    return objc_getAssociatedObject(self, @selector(originalIndexPath));
}

- (void)setOriginalIndexPath:(NSIndexPath *)originalIndexPath {
    objc_setAssociatedObject(self, @selector(originalIndexPath), originalIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)moveIndexPath {
    return objc_getAssociatedObject(self, @selector(moveIndexPath));
}

- (void)setMoveIndexPath:(NSIndexPath *)moveIndexPath {
    objc_setAssociatedObject(self, @selector(moveIndexPath), moveIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)xd_dataSource {
    return objc_getAssociatedObject(self, @selector(xd_dataSource));
}

- (void)setXd_dataSource:(id)xd_dataSource {
    objc_setAssociatedObject(self, @selector(xd_dataSource), xd_dataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)edgeTimer {
    return objc_getAssociatedObject(self, @selector(edgeTimer));
}

- (void)setEdgeTimer:(CADisplayLink *)edgeTimer {
    objc_setAssociatedObject(self, @selector(edgeTimer), edgeTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)checkCanMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.xd_dataSource respondsToSelector:@selector(xd_collectionView:canMoveItemAtIndexPath:)])
    {
        if (![self.xd_dataSource performSelector:@selector(xd_collectionView:canMoveItemAtIndexPath:) withObject:self withObject:indexPath])
        {
            return NO;
        }
    }
    return YES;
}


- (BOOL)xd_beginInteractiveMovementForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self checkCanMoveItemAtIndexPath:indexPath])
    {
        return NO;
    }
    else
    {
    
    }
    
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
    self.originalIndexPath = indexPath;
    if (cell)
    {
        UIView *tempMoveCell = [cell snapshotViewAfterScreenUpdates:NO];
        
        cell.hidden = YES;
        self.tempMoveCell = tempMoveCell;
        self.tempMoveCell.frame = cell.frame;
        [self addSubview:self.tempMoveCell];
        
        //开启边缘滚动定时器
        [self xd_setEdgeTimer];
        
        return YES;
    }
    return NO;
}

- (void)xd_updateInteractiveMovementTargetPosition:(CGPoint)targetPosition
{
//    if (self.tempMoveCell)
    {
        self.tempMoveCell.center = targetPosition;
        [self xd_moveCell];
    }
}

- (void)xd_endInteractiveMovement
{
//    if (self.tempMoveCell)
    {
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:self.originalIndexPath];
        self.userInteractionEnabled = NO;
        [self xd_stopEdgeTimer];
    //    //通知代理
    //    if ([self.delegate respondsToSelector:@selector(dragCellCollectionViewCellEndMoving:)]) {
    //        [self.delegate dragCellCollectionViewCellEndMoving:self];
    //    }
        [UIView animateWithDuration:0.25 animations:^{
            self.tempMoveCell.center = cell.center;
        } completion:^(BOOL finished) {
    //        [self xd_stopShakeAllCell];
            [self.tempMoveCell removeFromSuperview];
            self.tempMoveCell = nil;
            cell.hidden = NO;
            self.userInteractionEnabled = YES;
        }];
    }
}

- (void)xd_cancelInteractiveMovement
{
//    if (self.tempMoveCell)
    {
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:self.originalIndexPath];
        self.userInteractionEnabled = NO;
        [self xd_stopEdgeTimer];
        //    //通知代理
        //    if ([self.delegate respondsToSelector:@selector(dragCellCollectionViewCellEndMoving:)]) {
        //        [self.delegate dragCellCollectionViewCellEndMoving:self];
        //    }
        [UIView animateWithDuration:0.25 animations:^{
            self.tempMoveCell.center = cell.center;
        } completion:^(BOOL finished) {
            //        [self xd_stopShakeAllCell];
            [self.tempMoveCell removeFromSuperview];
            self.tempMoveCell = nil;
            cell.hidden = NO;
            self.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark - private methods

- (void)xd_moveCell{
    for (UICollectionViewCell *cell in [self visibleCells]) {
        if ([self indexPathForCell:cell] == self.originalIndexPath || cell.hidden == YES) {
            continue;
        }
        //计算中心距
        CGFloat spacingX = fabs(self.tempMoveCell.center.x - cell.center.x);
        CGFloat spacingY = fabs(self.tempMoveCell.center.y - cell.center.y);
        if (spacingX <= self.tempMoveCell.bounds.size.width / 2.0f && spacingY <= self.tempMoveCell.bounds.size.height / 2.0f) {
            self.moveIndexPath = [self indexPathForCell:cell];
//            NSLog(@"originalIndexPath = %d moveIndexPath = %d",[self.originalIndexPath row],[self.moveIndexPath row]);
            
            if (![self.moveIndexPath isEqual:self.originalIndexPath])
            {
                //移动
                [self moveItemAtIndexPath:self.originalIndexPath toIndexPath:self.moveIndexPath];
                
                if (self.xd_dataSource)
                {
                    [self.xd_dataSource xd_collectionView:self moveItemAtIndexPath:self.originalIndexPath toIndexPath:self.moveIndexPath];
                }
                //通知代理
                //            if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:moveCellFromIndexPath:toIndexPath:)]) {
                //                [self.delegate dragCellCollectionView:self moveCellFromIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
                //            }
                //设置移动后的起始indexPath
                self.originalIndexPath = self.moveIndexPath;
            }
//            else
//            {
//                NSLog(@"originalIndexPath = %d",[self.originalIndexPath row]);
//                NSLog(@"moveIndexPath = %d",[self.moveIndexPath row]);
//                NSLog(@"originalIndexPath == moveIndexPath");
//            }
            break;
        }
    }
}


#pragma mark - timer methods

- (void)xd_setEdgeTimer{
    if (!self.edgeTimer && self.edgeScrollEable) {
        self.edgeTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(xd_edgeScroll)];
        [self.edgeTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)xd_stopEdgeTimer{
    if (self.edgeTimer) {
        [self.edgeTimer invalidate];
        self.edgeTimer = nil;
    }
}

- (void)xd_setScrollDirection{
    self.scrollDirection = XWDragCellCollectionViewScrollDirectionNone;
    if (self.bounds.size.height + self.contentOffset.y - self.tempMoveCell.center.y < self.tempMoveCell.bounds.size.height / 2 && self.bounds.size.height + self.contentOffset.y < self.contentSize.height) {
        self.scrollDirection = XWDragCellCollectionViewScrollDirectionDown;
    }
    if (self.tempMoveCell.center.y - self.contentOffset.y < self.tempMoveCell.bounds.size.height / 2 && self.contentOffset.y > 0) {
        self.scrollDirection = XWDragCellCollectionViewScrollDirectionUp;
    }
    if (self.bounds.size.width + self.contentOffset.x - self.tempMoveCell.center.x < self.tempMoveCell.bounds.size.width / 2 && self.bounds.size.width + self.contentOffset.x < self.contentSize.width) {
        self.scrollDirection = XWDragCellCollectionViewScrollDirectionRight;
    }
    
    if (self.tempMoveCell.center.x - self.contentOffset.x < self.tempMoveCell.bounds.size.width / 2 && self.contentOffset.x > 0) {
        self.scrollDirection = XWDragCellCollectionViewScrollDirectionLeft;
    }
}

- (void)xd_edgeScroll{
    [self xd_setScrollDirection];
//    NSLog(@"self.scrollDirection = %d",self.scrollDirection);
    switch (self.scrollDirection) {
        case XWDragCellCollectionViewScrollDirectionLeft:{
            //这里的动画必须设为NO
            [self setContentOffset:CGPointMake(self.contentOffset.x - 4, self.contentOffset.y) animated:NO];
            self.tempMoveCell.center = CGPointMake(self.tempMoveCell.center.x - 4, self.tempMoveCell.center.y);
//            self.lastPoint.x -= 4;
            
        }
            break;
        case XWDragCellCollectionViewScrollDirectionRight:{
            [self setContentOffset:CGPointMake(self.contentOffset.x + 4, self.contentOffset.y) animated:NO];
            self.tempMoveCell.center = CGPointMake(self.tempMoveCell.center.x + 4, self.tempMoveCell.center.y);
//            self.lastPoint.x += 4;
            
        }
            break;
        case XWDragCellCollectionViewScrollDirectionUp:{
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - 4) animated:NO];
            self.tempMoveCell.center = CGPointMake(self.tempMoveCell.center.x, self.tempMoveCell.center.y - 4);
//            _lastPoint.y -= 4;
        }
            break;
        case XWDragCellCollectionViewScrollDirectionDown:{
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + 4) animated:NO];
            self.tempMoveCell.center = CGPointMake(self.tempMoveCell.center.x, self.tempMoveCell.center.y + 4);
//            _lastPoint.y += 4;
        }
            break;
        default:
            break;
    }
    
}


@end
