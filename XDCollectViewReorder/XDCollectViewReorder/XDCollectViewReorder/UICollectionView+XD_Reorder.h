//
//  UICollectionView+XD_Reorder.h
//  XDBookShelf
//
//  Created by 施孝达 on 16/4/5.
//  Copyright © 2016年 施孝达. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDCollectionViewDataSource.h"

@interface UICollectionView (XD_Reorder)
@property (nonatomic, weak) id <XDCollectionViewDataSource> xd_dataSource;
/**是否开启拖动到边缘滚动CollectionView的功能，默认NO*/
@property (nonatomic, assign) BOOL edgeScrollEable;
// Support for reordering
- (BOOL)xd_beginInteractiveMovementForItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0); // returns NO if reordering was prevented from beginning - otherwise YES
- (void)xd_updateInteractiveMovementTargetPosition:(CGPoint)targetPosition NS_AVAILABLE_IOS(6_0);
- (void)xd_endInteractiveMovement NS_AVAILABLE_IOS(6_0);
- (void)xd_cancelInteractiveMovement NS_AVAILABLE_IOS(6_0);
@end
