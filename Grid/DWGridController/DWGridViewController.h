//
//  DWGridViewController.h
//  Grid
//
//  Created by Alvin Nutbeij on 12/14/12.
//  Copyright (c) 2013 Devwire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWGridView.h"
@interface DWGridViewController : UIViewController <DWGridViewDataSource, DWGridViewDelegate>

@property (nonatomic, retain) DWGridView *gridView;
@property (nonatomic, retain) NSMutableArray *cells;
@property (nonatomic,retain ) NSArray *Items;
@property (nonatomic,retain) NSDictionary* json;
-(NSMutableDictionary *)cellDictionaryAtPosition:(DWPosition)position;
-(void) addItems:(NSArray *)toAdd;
@end
