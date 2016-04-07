//
//  XDCollectionViewDataSource.h
//  XDBookShelf
//
//  Created by 施孝达 on 16/4/5.
//  Copyright © 2016年 施孝达. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XDCollectionViewDataSource <NSObject>

@optional

- (BOOL)xd_collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0);
- (void)xd_collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath NS_AVAILABLE_IOS(6_0);

@end
