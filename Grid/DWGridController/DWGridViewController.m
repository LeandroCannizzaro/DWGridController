//
//  DWGridViewController.m
//  Grid
//
//  Created by Alvin Nutbeij on 12/14/12.
//  Copyright (c) 2013 Devwire. All rights reserved.
//

#import "DWGridViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kLatestKivaLoansURL [NSURL URLWithString: @"http://api.yoox.biz/YooxCore.API/1.0/YOOX_US/SearchResults?dept=women&Gender=D&noItems=0&noRef=0&page=1"]

@interface DWGridViewController ()
-(DWPosition)normalizePosition:(DWPosition)position inGridView:(DWGridView *)gridView;
@end

@implementation DWGridViewController
@synthesize gridView = _gridView;
@synthesize cells = _cells;
@synthesize Items = _Items;
@synthesize json = _json;

//NSDictionary* json;
-(id)init
{
    self = [super init];
    if(self)
    {
        _gridView = [[DWGridView alloc] init];
        _cells = [[NSMutableArray alloc] init];
        [self createView];
    }
    
    return self;
}


- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    self.json = [NSJSONSerialization
            JSONObjectWithData:responseData //1

                       options:kNilOptions
                         error:&error];


    //self.gridView.Items = [self.json objectForKey:@"Items"];
    //self.gridView.Items[0]
    //NSLog(@"ITEMS",self.gridView.Items);
    //[[self.gridView.dataSource.Items] json objectForKey:@"Items"];

    //NSArray *I = [self.gridView.dataSource Items];
    //I = [json objectForKey:@"Items"];

    //[self Items:self.gridView.dataSource ] = [json objectForKey:@"Items"]; //2
    //Refinements = [json objectForKey:@"Refinements"]; //2
    //Attributes = [json objectForKey:@"Attributes"]; //2


    //NSLog(@"loans: %@", latestLoans); //3
}

-(void)downloadData{

}

- (void)addItems:(NSArray *)toAdd{
    _Items = [_Items  arrayByAddingObjectsFromArray: toAdd];
}

- (id)createView
{
    if (self) {


        //NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSError* error;
        NSData* data = [NSData dataWithContentsOfURL:kLatestKivaLoansURL];
        _json = [NSJSONSerialization
                JSONObjectWithData:data
                options:kNilOptions
                  error:&error];
        //self.gridView.Items = [_json objectForKey:@"Items"];
        _Items = [_json objectForKey:@"Items"];
//self.Items = [json objectForKey:@"Items"];
//        dispatch_async(kBgQueue, ^{
//            NSData* data = [NSData dataWithContentsOfURL: kLatestKivaLoansURL];
//            [self performSelectorOnMainThread:@selector(fetchedData:)
//                                   withObject:data waitUntilDone:YES];
//        });


        //fetch total grid size

        NSInteger  _numberOfRowsInGrid = [self numberOfRowsInGridView:self.gridView];
        NSInteger _numberOfColumnsInGrid = [self numberOfColumnsInGridView:self.gridView];

        for(int row = 0; row < _numberOfRowsInGrid; row++){
            for(int col = 0; col < _numberOfColumnsInGrid; col++){
                DWGridViewCell *cell = [[DWGridViewCell alloc] init];
                cell.backgroundColor = [UIColor blueColor];

                //UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d-%d.jpeg",row,col]];
                //UIImageView *iv = [[UIImageView alloc] initWithImage:image];
                UIImageView *iv = [[UIImageView alloc] init];

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
                //[dict setObject:tv.text forKey:@"Text"];

                //if(image)
                //    [dict setObject:image forKey:@"Image"];
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
    return 2;
}

-(NSInteger)numberOfRowsInGridView:(DWGridView *)gridView{
    return 2;
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

-(void)loadView
{
//    _gridView = [[DWGridView alloc] init];
    _gridView.delegate = self;
    _gridView.dataSource = self;
    _gridView.clipsToBounds = YES;
    self.view = _gridView;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_gridView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GridView delegate
-(void)gridView:(DWGridView *)gridView didMoveCell:(DWGridViewCell *)cell fromPosition:(DWPosition)fromPosition toPosition:(DWPosition)toPosition{
    //moving vertically
    toPosition = [gridView normalizePosition:toPosition];
    if(toPosition.column == fromPosition.column)
    {
        //How many places is the tile moved (can be negative!)
        NSInteger amount = toPosition.row - fromPosition.row;
        NSMutableDictionary *cellDict = [self cellDictionaryAtPosition:fromPosition];
        NSMutableDictionary *toCell;
        do
        {
            //Get the next cell
            toCell = [self cellDictionaryAtPosition:toPosition];
            
            //update the current cell
            [cellDict setObject:[NSNumber numberWithInt:toPosition.row] forKey:@"Row"];
            
            //prepare the next cell
            cellDict = toCell;
            
            //calculate the next position
            toPosition.row += amount;
            
            toPosition = [gridView normalizePosition:toPosition];
        }while (toCell);
    }
    else //moving horizontally
    {
        //How many places is the tile moved (can be negative!)
        NSInteger amount = toPosition.column - fromPosition.column;
        NSMutableDictionary *cellDict = [self cellDictionaryAtPosition:fromPosition];
        NSMutableDictionary *toCell;
        do
        {
            //Get the next cell
            toCell = [self cellDictionaryAtPosition:toPosition];
            
            //update the current cell
            [cellDict setObject:[NSNumber numberWithInt:toPosition.column] forKey:@"Column"];
            
            //prepare the next cell
            cellDict = toCell;
            
            //calculate the next position
            toPosition.column += amount;
            toPosition = [gridView normalizePosition:toPosition];
        }while (toCell);
        
    }
}

#pragma mark - GridView delegate
-(void)gridView:(DWGridView *)gridView didMoveRow:(DWGridViewCell *)cell fromPosition:(DWPosition)fromPosition toPosition:(DWPosition)toPosition{
    //moving vertically
    toPosition = [gridView normalizePosition:toPosition];
    if(toPosition.column == fromPosition.column)
    {
        //How many places is the tile moved (can be negative!)
        NSInteger amount = toPosition.row - fromPosition.row;
        NSMutableDictionary *cellDict = [self cellDictionaryAtPosition:fromPosition];
        NSMutableDictionary *toCell;
        do
        {
            //Get the next cell
            toCell = [self cellDictionaryAtPosition:toPosition];
            
            //update the current cell
            [cellDict setObject:[NSNumber numberWithInt:toPosition.row] forKey:@"Row"];
            
            //prepare the next cell
            cellDict = toCell;
            
            //calculate the next position
            toPosition.row += amount;
            
            toPosition = [gridView normalizePosition:toPosition];
        }while (toCell);
    }
    else //moving horizontally
    {
        //How many places is the tile moved (can be negative!)
        NSInteger amount = toPosition.column - fromPosition.column;
        NSMutableDictionary *cellDict = [self cellDictionaryAtPosition:fromPosition];
        NSMutableDictionary *toCell;
        do
        {
            //Get the next cell
            toCell = [self cellDictionaryAtPosition:toPosition];
            
            //update the current cell
            [cellDict setObject:[NSNumber numberWithInt:toPosition.column] forKey:@"Column"];
            
            //prepare the next cell
            cellDict = toCell;
            
            //calculate the next position
            toPosition.column += amount;
            toPosition = [gridView normalizePosition:toPosition];
        }while (toCell);
        
    }
}


-(DWGridViewCell *)gridView:(DWGridView *)gridView cellAtPosition:(DWPosition)position{
    DWGridViewCell *cell = [[self cellDictionaryAtPosition:position] objectForKey:@"Cell"];
    
    if(!cell){
        cell = [[DWGridViewCell alloc] init];
    }
    return cell;
}

#pragma mark - Screen rotation

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskLandscape;
    return UIInterfaceOrientationMaskPortrait;

}

#pragma mark - Private methods
-(DWPosition)normalizePosition:(DWPosition)position inGridView:(DWGridView *)gridView{
    return [gridView normalizePosition:position];
}

#pragma mark - Public methods

-(NSMutableDictionary *)cellDictionaryAtPosition:(DWPosition)position
{
    position = [self normalizePosition:position inGridView:_gridView];
    for(NSMutableDictionary *cellDict in _cells){
        if([[cellDict objectForKey:@"Row"] intValue] == position.row){
            if([[cellDict objectForKey:@"Column"] intValue] == position.column){
                return cellDict;
            }else{
                continue;
            }
        }else{
            continue;
        }
    }
    
    return nil;
}
@end
