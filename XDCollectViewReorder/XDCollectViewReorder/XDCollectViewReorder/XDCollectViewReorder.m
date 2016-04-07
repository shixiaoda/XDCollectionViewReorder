//
//  XDCollectViewReorder.m
//  XDCollectViewReorder
//
//  Created by 施孝达 on 16/4/7.
//  Copyright © 2016年 shixiaoda. All rights reserved.
//

#import "XDCollectViewReorder.h"

typedef void(^GestureStateChangeBlocks)(UILongPressGestureRecognizer *gestureRecognizer);

#define IOS9 [[UIDevice currentDevice].systemVersion doubleValue] >= 9.0

@interface XDCollectViewReorder () {
    UILongPressGestureRecognizer *_moveGesture;
    GestureStateChangeBlocks _moveGestureStateChangeBlocks;
}
@end


@implementation XDCollectViewReorder
#pragma mark - Initialize method
- (instancetype)init {
    self = [super init];
    if (self) {
        _moveGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveGestureAction:)];
    }
    return self;
}

- (void)bindToCollectionView:(UICollectionView *)collectionView {
    [collectionView addGestureRecognizer:_moveGesture];
    _moveGestureStateChangeBlocks = ^(UILongPressGestureRecognizer *gestureRecognizer) {
        
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:{
                if (IOS9)
                {
                    [collectionView beginInteractiveMovementForItemAtIndexPath:[collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:collectionView]]];
                    CGPoint tapLocation = [gestureRecognizer locationInView:[gestureRecognizer view]];
                    [collectionView updateInteractiveMovementTargetPosition:CGPointMake(tapLocation.x+5, tapLocation.y+5)];
                }
                else
                {
                    [collectionView xd_beginInteractiveMovementForItemAtIndexPath:[collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:collectionView]]];
                    CGPoint tapLocation = [gestureRecognizer locationInView:[gestureRecognizer view]];
                    [collectionView xd_updateInteractiveMovementTargetPosition:CGPointMake(tapLocation.x+5, tapLocation.y+5)];
                }
                
            }
                break;
            case UIGestureRecognizerStateChanged:{
                if (IOS9)
                {
                    [collectionView updateInteractiveMovementTargetPosition:[gestureRecognizer locationInView:[gestureRecognizer view]]];
                }
                else
                {
                    [collectionView xd_updateInteractiveMovementTargetPosition:[gestureRecognizer locationInView:[gestureRecognizer view]]];
                }
            }
                break;
            case UIGestureRecognizerStateEnded:{
                if (IOS9)
                {
                    [collectionView endInteractiveMovement];
                }
                else
                {
                    [collectionView xd_endInteractiveMovement];
                }
            }
                break;
            default:{
                if (IOS9)
                {
                    [collectionView cancelInteractiveMovement];
                }
                else
                {
                    [collectionView xd_endInteractiveMovement];
                }
            }
                break;
        }
    };
    
}

#pragma mark - MoveGesture Action
- (void)moveGestureAction:(id)sender {
    if (_moveGestureStateChangeBlocks) {
        _moveGestureStateChangeBlocks(sender);
    }
}

@end
