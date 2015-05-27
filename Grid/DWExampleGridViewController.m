//
//  DWExampleGridViewController.m
//  Grid
//
//  Created by Alvin Nutbeij on 2/19/13.
//  Copyright (c) 2013 NCIM Groep. All rights reserved.
//

#import "DWExampleGridViewController.h"
#import "DWExampleGridViewCell.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kLatestKivaLoansURL [NSURL URLWithString: @"http://api.yoox.biz/YooxCore.API/1.0/YOOX_US/SearchResults?dept=women&Gender=D&noItems=0&noRef=0&page=1"]
//http://api.kivaws.org/v1/loans/search.json?status=fundraising"] //2

@interface DWExampleGridViewController ()

@end

@implementation DWExampleGridViewController

NSArray* Items;
NSArray* Refinements;
NSArray* Attributes;
NSInteger itemsPointer;

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
            JSONObjectWithData:responseData //1

                       options:kNilOptions
                         error:&error];


    Items = [json objectForKey:@"Items"]; //2
    Refinements = [json objectForKey:@"Refinements"]; //2
    Attributes = [json objectForKey:@"Attributes"]; //2


    //NSLog(@"loans: %@", latestLoans); //3
}

- (id)init
{
    self = [super init];
    if (self) {


        //NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];


        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                    kLatestKivaLoansURL];
            [self performSelectorOnMainThread:@selector(fetchedData:)
                                   withObject:data waitUntilDone:YES];
        });


        //fetch total grid size

        NSInteger  _numberOfRowsInGrid = [self numberOfRowsInGridView:self.gridView];
        NSInteger _numberOfColumnsInGrid = [self numberOfColumnsInGridView:self.gridView];

        for(int row = 0; row < _numberOfRowsInGrid; row++){
            for(int col = 0; col < _numberOfColumnsInGrid; col++){
                DWExampleGridViewCell *cell = [[DWExampleGridViewCell alloc] init];
                cell.backgroundColor = [UIColor blueColor];

                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d-%d.jpeg",row,col]];
                UIImageView *iv = [[UIImageView alloc] initWithImage:image];
                //UIImageView *iv = [[UIImageView alloc] init];
                [iv setContentMode:UIViewContentModeScaleAspectFill];
                iv.clipsToBounds = YES;
                [iv setTranslatesAutoresizingMaskIntoConstraints:NO];
                iv.backgroundColor = [UIColor redColor];
                iv.tag="image";
                [cell addSubview:iv];

                CGFloat h = 50;
                UITextView *tv = [[UITextView alloc] init];
                tv.backgroundColor = [UIColor brownColor];
               // initWithFrame:CGRectMake(10, 10,  300, 100 + 16)];
                [tv setFont:[UIFont systemFontOfSize:14]];
                tv.text = [NSString stringWithFormat:@"XX %d-%d",row,col];
                tv.userInteractionEnabled = NO;
                tv.tag="text";
                [tv setContentMode:UIViewContentModeScaleAspectFill];
                //tv.clipsToBounds = YES;
                [tv setTranslatesAutoresizingMaskIntoConstraints:NO];
                [cell addSubview:tv];
                
//                [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[iv]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(iv)]];
//                [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[iv]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(iv)]];

//                [cell addConstraint:[NSLayoutConstraint constraintWithItem:iv
//                                                                 attribute:NSLayoutAttributeWidth
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:cell
//                                                                 attribute:NSLayoutAttributeWidth
//                                                                multiplier:0.5
//                                                                  constant:0]];

//                [cell addConstraint:[NSLayoutConstraint constraintWithItem:tv
//                                                                 attribute:NSLayoutAttributeWidth
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:nil
//                                                                 attribute:NSLayoutAttributeWidth
//                                                                multiplier:0.5
//                                                                  constant:30]];
//                [cell addConstraint:[NSLayoutConstraint constraintWithItem:tv
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:nil
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                multiplier:0.5
//                                                                  constant:30]];

                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:cell forKey:@"Cell"];
                [dict setObject:[NSNumber numberWithInt:row] forKey:@"Row"];
                [dict setObject:[NSNumber numberWithInt:col] forKey:@"Column"];
                [dict setObject:tv.text forKey:@"Text"];

                if(image)
                    [dict setObject:image forKey:@"Image"];
                [self.cells addObject:dict];
                
            }
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - GridView datasource
-(NSInteger)numberOfColumnsInGridView:(DWGridView *)gridView{
    return 4;
}

-(NSInteger)numberOfRowsInGridView:(DWGridView *)gridView{
    return 4;
}

-(NSInteger)numberOfVisibleRowsInGridView:(DWGridView *)gridView{
    return 2;
}

-(NSInteger)numberOfVisibleColumnsInGridView:(DWGridView *)gridView{
    return 2;
}

#pragma mark - GridView delegate
-(void)gridView:(DWGridView *)gridView didSelectCell:(DWGridViewCell *)cell atPosition:(DWPosition)position
{
    NSDictionary *cellDictionary = [self cellDictionaryAtPosition:position];
    UIImage *image = [cellDictionary objectForKey:@"Image"];
    
    UIButton *button = [[UIButton alloc] init];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchDown];
    
    UIViewController *contr = [[UIViewController alloc] init];
    [contr.view addSubview:button];
    
    [contr.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[button]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
    [contr.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[button]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
    
    [self presentViewController:contr animated:YES completion:nil];
}

-(void)buttonTapped
{
    [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
}
@end
