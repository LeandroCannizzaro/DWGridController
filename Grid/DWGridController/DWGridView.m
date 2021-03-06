//
//  DWGridView.m
//  Grid
//
//  Created by Alvin Nutbeij on 12/14/12.
//  Copyright (c) 2013 Devwire. All rights reserved.
//

#import "DWGridView.h"

@interface DWGridView ( Private )

-(void)panGestureDetected:(UIGestureRecognizer *)gestureRecognizer;
-(void)initCells;
/**
 *  This method will always generate a unique tag for a view based on row and column.
 *
 *  @warning *Important* This will only work if the row and column counter start at 0.
 *
 *  @param position The cell's position
 *
 *  @return The tag
 */
-(NSInteger)tagForPosition:(DWPosition)position;

//-(NSArray*) Items;

@end

@implementation DWGridView
@synthesize delegate;
@synthesize dataSource;

static const CGFloat stepSize = 300.0;
static const NSInteger outerOffset = 0; //1;

//@synthesize Items;
//NSArray* Items;
//NSArray* Refinements;
//NSArray* Attributes;
NSInteger itemsPointer = 0;
NSInteger currentPage = 1;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //set touch position to something non-existant
        _lastTouchedPosition = DWPositionMake(-1337, -1337);
        
        //self can't have tag 0 because there is a tile with tag 0 which will conflict when moving
        self.tag = 1337;
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
        [self addGestureRecognizer:_panRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetected:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)reloadData
{
    //fetch total grid size
    _numberOfRowsInGrid = [self.dataSource numberOfRowsInGridView:self];
    _numberOfColumnsInGrid = [self.dataSource numberOfColumnsInGridView:self];
    
    //fetch the visible grid size
    if([self.dataSource respondsToSelector:@selector(numberOfVisibleRowsInGridView:)])
        _numberOfVisibleRowsInGrid = [self.dataSource numberOfVisibleRowsInGridView:self];
    else
        _numberOfVisibleRowsInGrid = _numberOfRowsInGrid;
    
    if([self.dataSource respondsToSelector:@selector(numberOfVisibleColumnsInGridView:)])
        _numberOfVisibleColumnsInGrid = [self.dataSource numberOfVisibleColumnsInGridView:self];
    else
        _numberOfVisibleColumnsInGrid = _numberOfColumnsInGrid;
    
    [self initCells];
}

-(void)initCells
{
    //remove all subviews
    // [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //fetch the bounds, will be used to position the cells
    CGRect myFrame = self.bounds;
    
    //loop through the rows with 2 above and 2 below the screen
    for(int row = -outerOffset; row < _numberOfVisibleRowsInGrid+outerOffset; row++)
    {
        //loop through the columns with 2 left and 2 right of the screen
        for(int column = -outerOffset; column < _numberOfVisibleColumnsInGrid+outerOffset; column++)
        {

            //Skip items that can't be reached
            if([self shouldSkipItemAtRow:row column:column])
            {
               continue;
            }
            
            //fetch the cell for the current position
            DWPosition cellPosition = DWPositionMake(row, column);
            DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:cellPosition];
            cell.tag = [self tagForPosition:cellPosition];
            
            //create the frame based on the current position, the view's bounds and the grid's size
            CGRect cellFrame;
            cellFrame.size.width = myFrame.size.width / _numberOfVisibleColumnsInGrid;
            cellFrame.size.height = myFrame.size.height / _numberOfVisibleRowsInGrid;
            cellFrame.origin.x = column * cellFrame.size.width;
            cellFrame.origin.y = row * cellFrame.size.height;
            cell.frame = cellFrame;

            UITextView *t;
            UIImageView *i;

            //add the cell to the grid view
            if(![self.subviews containsObject:cell])
            {
                [self addSubview:cell];

                //NSArray *subviews = [view subviews];

                t = (UITextView *)[cell viewWithTag:"text"];
                //[t sizeThatFits:<#(CGSize)size#>]
                CGRect frame = t.frame;
                frame.size.width = cell.bounds.size.width;
                //frame.size.height = 10 * row;
                frame.size.height = 2.5 * t.font.lineHeight;
                frame.origin.y = cell.bounds.size.height - frame.size.height;
                //t.text = @"pippo";
                //CGSize textSize = [t.text sizeWithFont:t.font forWidth:frame.size.width lineBreakMode: UILineBreakModeTailTruncation];
                //frame.size.height = textSize.height;
                t.frame = frame;

                i = (UIImageView *)[cell viewWithTag:"image"];
                frame = i.frame;
                frame.size.width = cell.bounds.size.width;
                frame.size.height = cell.bounds.size.height - t.bounds.size.height;
                frame.origin.y = 0; //cell.bounds.size.height - frame.size.height;
                i.frame = frame;
                //i.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d-%d.jpeg",row,column]];


            }else{
                i = (UIImageView *)[cell viewWithTag:"image"];
                t = (UITextView *)[cell viewWithTag:"text"];
            }

            NSString *cod10 = [delegate.Items[itemsPointer * row + column] objectForKey: @"Cod10"];
            NSString* txt  =  @(itemsPointer).stringValue;
            txt = [txt stringByAppendingString: @"-" ];
            txt = [txt stringByAppendingString: @(row).stringValue ];
            txt = [txt stringByAppendingString: @"-" ];
            txt = [txt stringByAppendingString: @(column).stringValue ];
            txt = [txt stringByAppendingString: @"-" ];
            txt = [txt stringByAppendingString: @(currentPage).stringValue ];
            txt = [txt stringByAppendingString: @"-" ];
            txt = [txt stringByAppendingString: cod10];
            t.text =  txt ;

            //http://cdn.yoox.biz/39/39432350JM_11_f.jpg
            NSString* x = @"http://cdn.yoox.biz/";

            x = [x stringByAppendingString: [cod10 substringWithRange:NSMakeRange(0,2)]];
            x = [x stringByAppendingString: @"/"];
            x = [x stringByAppendingString: cod10];
            x = [x stringByAppendingString: @"_11_f.jpg"];

            NSURL *imageURL = [NSURL URLWithString:x];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];

                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI
                    i.image = [UIImage imageWithData:imageData];
                });
            });

            //if the cell is on screen bring it to the front
            if(row >= 0 && row < _numberOfVisibleRowsInGrid && column >= 0 && column < _numberOfVisibleColumnsInGrid)
            {
                [self bringSubviewToFront:cell];
            }
            //if the cell is off screen send it to the bck
            else
            {
                [self sendSubviewToBack:cell];
            }
        }
    }
    itemsPointer++;
    if (currentPage * (itemsPointer * _numberOfVisibleRowsInGrid + _numberOfVisibleColumnsInGrid) > delegate.Items.count)
    {
        currentPage++;
        NSString* x = @"http://api.yoox.biz/YooxCore.API/1.0/YOOX_US/SearchResults?dept=women&Gender=D&noItems=0&noRef=0&page=";

        x = [x stringByAppendingString: @(currentPage).stringValue];

        NSURL* xx = [NSURL URLWithString:x ];

        NSError* error;
        NSData* data = [NSData dataWithContentsOfURL:xx];
        NSDictionary * _json = [NSJSONSerialization
                JSONObjectWithData:data
                           options:kNilOptions
                             error:&error];
        //self.gridView.Items = [_json objectForKey:@"Items"];

        //_Items = [_json objectForKey:@"Items"];
        NSArray * xxx = [_json objectForKey:@"Items"];
        //NSArray * yyy = Items;
        [delegate addItems:xxx];
        //delegate.Items = [delegate.Items  arrayByAddingObjectsFromArray: xxx];
    }
}

-(BOOL)shouldSkipItemAtRow:(int)row column:(int)column
{
    BOOL skip = NO;
    if(row < 0 && column < 0)
    {
        skip = YES;
    }
    
    if(row < 0 && column >= _numberOfVisibleColumnsInGrid)
    {
        skip = YES;
    }
    
    if(row >= _numberOfVisibleRowsInGrid && column < 0)
    {
        skip = YES;
    }
    
    if(row >= _numberOfVisibleRowsInGrid && column >= _numberOfVisibleColumnsInGrid)
    {
        skip = YES;
    }
    
    return skip;
}

-(NSInteger)tagForPosition:(DWPosition)position
{
    NSInteger tag = position.row * _numberOfColumnsInGrid + position.column;
    //tag 0 gives issues with moving (for some reason?)
    //Therefor we set it to INT_MAX, as that will never be reached
    if(tag == 0)
    {
        tag = INT_MAX;
    }
    return tag;
}

#pragma mark - DWPosition

static inline DWPosition DWPositionMake(NSInteger row, NSInteger column)
{
    return (DWPosition) {row, column};
}

-(DWPosition)determinePositionAtPoint:(CGPoint)point
{
    DWPosition position;
    CGFloat height = self.bounds.size.height;
    CGFloat posY = point.y;
    CGFloat rowHeight = height / _numberOfVisibleRowsInGrid;
    position.row = floor(posY / rowHeight);
    
    CGFloat width = self.bounds.size.width;
    CGFloat posX = point.x;
    CGFloat columnWidth = width / _numberOfVisibleColumnsInGrid;
    position.column = floor(posX / columnWidth);
    
    return position;
}

-(DWPosition)normalizePosition:(DWPosition)position
{
    
    if(position.row < 0)
    {
        position.row += _numberOfRowsInGrid;
    }else if(position.row >= _numberOfRowsInGrid)
    {
        position.row -= _numberOfRowsInGrid;
    }
    
    if(position.column < 0)
    {
        position.column += _numberOfColumnsInGrid;
    }else if(position.column >= _numberOfColumnsInGrid)
    {
        position.column -= _numberOfColumnsInGrid;
    }
    
    return position;
}

#pragma mark - Gestures

-(void)panGestureDetected:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [gestureRecognizer velocityInView:self];
    
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if(_easeOutTimer)
        {
            [_easeOutTimer invalidate];
            [_easeOutTimer finalize];
            _easeOutTimer = nil;
        }
        
        if(_easeThread)
        {
            [_easeThread cancel];
            _easeThread = nil;
        }
        
        DWPosition touchPosition = [self determinePositionAtPoint:[gestureRecognizer locationInView:self]];
        
        BOOL shouldReload = NO;
        shouldReload = _lastTouchedPosition.row < 0;
        shouldReload = shouldReload ? shouldReload : (_lastTouchedPosition.row != touchPosition.row && _isMovingHorizontally);
        shouldReload = shouldReload ? shouldReload : (fabsf(velocity.y) > fabsf(velocity.x) && _isMovingHorizontally);
        shouldReload = shouldReload ? shouldReload : (_lastTouchedPosition.column != touchPosition.column && _isMovingVertically);
        shouldReload = shouldReload ? shouldReload : (fabsf(velocity.x) > fabsf(velocity.y) && _isMovingVertically);
        
        if(shouldReload)
        {
            _lastTouchedPosition = touchPosition;
            [self reloadData];
            _isMovingHorizontally = NO;
            _isMovingVertically = NO;
        }
	}
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        //horizontal
        if(fabsf(velocity.x) > fabsf(velocity.y) && !_isMovingVertically)
        {
            _isMovingHorizontally = YES;
            DWPosition touchPosition = _lastTouchedPosition;//[self determinePositionAtPoint:[gestureRecognizer locationInView:self]];
            CGPoint translation = [gestureRecognizer translationInView:self];
            //[self moveCellAtPosition:touchPosition horizontallyBy:velocity.x withTranslation:translation reloadingData:YES];
            [self moveColumnAtPosition:touchPosition horizontallyBy:velocity.x withTranslation:translation reloadingData:YES];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
            
        }
        //vertical
        else if(!_isMovingHorizontally)
        {
            _isMovingVertically = YES;
            DWPosition touchPosition = _lastTouchedPosition;//[self determinePositionAtPoint:[gestureRecognizer locationInView:self]];
            CGPoint translation = [gestureRecognizer translationInView:self];
            [self moveCellAtPosition:touchPosition verticallyBy:velocity.y withTranslation:translation reloadingData:YES];
            //[self moveRowAtPosition:touchPosition verticallyBy:velocity.y withTranslation:translation reloadingData:YES];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        }
	}
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        DWPosition touchPosition = _lastTouchedPosition;//[self determinePositionAtPoint:[gestureRecognizer locationInView:self]];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithFloat:velocity.x] forKey:@"VelocityX"];
        [dict setObject:[NSNumber numberWithFloat:velocity.y] forKey:@"VelocityY"];
        [dict setObject:[NSNumber numberWithFloat:touchPosition.row] forKey:@"TouchRow"];
        [dict setObject:[NSNumber numberWithFloat:touchPosition.column] forKey:@"TouchColumn"];
        _easeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(easeOut:) userInfo:dict repeats:NO];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    DWPosition touchPosition = [self determinePositionAtPoint:[touch locationInView:self]];
    
    if(touchPosition.row == _lastTouchedPosition.row || touchPosition.column == _lastTouchedPosition.column)
    {
        [_easeThread cancel];
    }
}

-(void)tapGestureDetected:(UITapGestureRecognizer *)gesture
{
    if(_lastTouchedPosition.row >= 0 && _lastTouchedPosition.column >= 0)
    {
        [_easeThread cancel];
        _easeThread = nil;
        [UIView animateWithDuration:.2 animations:^
        {
            [self reloadData];
        } completion:^(BOOL finished)
         {
             _lastTouchedPosition = DWPositionMake(-55, -55);
         }];
    }
    
    if([self.delegate respondsToSelector:@selector(gridView:didSelectCell:atPosition:)])
    {
        DWPosition touchPosition = [self determinePositionAtPoint:[gesture locationInView:self]];
        if(touchPosition.row != _lastTouchedPosition.row && touchPosition.column != _lastTouchedPosition.column)
        {
            DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:touchPosition];
            [self.delegate gridView:self didSelectCell:cell atPosition:touchPosition];
        }
    }
    
}

#pragma mark - movement

-(void)moveCellSelector:(NSDictionary *)params
{
    
    CGFloat velocity = [[params objectForKey:@"velocity"] floatValue];
    BOOL reloadingData = [[params objectForKey:@"reloadingData"] boolValue];
    CGPoint translation = CGPointMake([[params objectForKey:@"translationX"] floatValue], [[params objectForKey:@"translationY"] floatValue]);
    BOOL isMovingHorizontally = [[params objectForKey:@"isMovingHorizontally"] boolValue];
    DWPosition position = DWPositionMake([[params objectForKey:@"positionX"] intValue], [[params objectForKey:@"positionY"] intValue]);
    
    if(isMovingHorizontally)
    {
        [self moveColumnAtPosition:position horizontallyBy:velocity withTranslation:translation reloadingData:reloadingData];
    }
    else
    {
        [self moveRowAtPosition:position verticallyBy:velocity withTranslation:translation reloadingData:reloadingData];
    }
}

-(void)easeRow:(NSDictionary *)params
{
    CGPoint velocity = CGPointMake([[params objectForKey:@"VelocityX"] floatValue], [[params objectForKey:@"VelocityY"] floatValue]);
    DWPosition touchPosition = DWPositionMake([[params objectForKey:@"TouchRow"] floatValue], [[params objectForKey:@"TouchColumn"] floatValue]);
    
    CGFloat width = self.bounds.size.width;
    CGFloat columnWidth = width / _numberOfVisibleColumnsInGrid;
    
    if( fabsf(velocity.x) < columnWidth)
    {
        if (velocity.x < 0 )
        {
            velocity.x = -columnWidth;
        }
        else 
        {
            velocity.x = columnWidth;
        }
    }
    
    CGFloat direction = velocity.x / stepSize;
    if(velocity.x < 0) //moving left
    {
        for(CGFloat i = 0; ![[NSThread currentThread] isCancelled]; i+=fabsf(direction))
        {
            if( i >= fabsf(velocity.x) - columnWidth)
            {
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:DWPositionMake(touchPosition.row, 0)];
                if((int)roundf(cell.frame.origin.x) % (int)roundf(columnWidth) == 0)
                {
                    if(cell.frame.origin.x != 0)
                    {
                        direction = cell.frame.origin.x - columnWidth;
                        
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithFloat:velocity.x], @"velocity",
                                              [NSNumber numberWithBool:YES], @"reloadingData",
                                              [NSNumber numberWithFloat:direction], @"translationX",
                                              [NSNumber numberWithFloat:0], @"translationY",
                                              [NSNumber numberWithBool:YES], @"isMovingHorizontally",
                                              [NSNumber numberWithInt:touchPosition.row], @"positionX",
                                              [NSNumber numberWithInt:0], @"positionY",
                                              nil];
                        [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
                    }
                    break;
                }
            }
            
            direction = (velocity.x + i) / stepSize;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:velocity.x], @"velocity",
                                  [NSNumber numberWithBool:YES], @"reloadingData",
                                  [NSNumber numberWithFloat:direction], @"translationX",
                                  [NSNumber numberWithFloat:0], @"translationY",
                                  [NSNumber numberWithBool:YES], @"isMovingHorizontally",
                                  [NSNumber numberWithInt:touchPosition.row], @"positionX",
                                  [NSNumber numberWithInt:touchPosition.column], @"positionY",
                                  nil];
            [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
            [NSThread sleepForTimeInterval:0.001];
        }
    }
    else //moving right
    {
        for(CGFloat i = 0; ![[NSThread currentThread] isCancelled]; i+=fabsf(direction))
        {
            if( i >= fabsf(velocity.x) - columnWidth)
            {
                DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:DWPositionMake(touchPosition.row, 0)];
                if((int)roundf(cell.frame.origin.x) % (int)roundf(columnWidth) == 0)
                {
                    if(cell.frame.origin.x != 0)
                    {
                        direction = columnWidth - cell.frame.origin.x;
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithFloat:velocity.x], @"velocity",
                                              [NSNumber numberWithBool:YES], @"reloadingData",
                                              [NSNumber numberWithFloat:direction], @"translationX",
                                              [NSNumber numberWithFloat:0], @"translationY",
                                              [NSNumber numberWithBool:YES], @"isMovingHorizontally",
                                              [NSNumber numberWithInt:touchPosition.row], @"positionX",
                                              [NSNumber numberWithInt:0], @"positionY",
                                              nil];
                        [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
                    }
                    break;
                }
            }
            
            direction = (velocity.x - i) / stepSize;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:velocity.x], @"velocity",
                                  [NSNumber numberWithBool:YES], @"reloadingData",
                                  [NSNumber numberWithFloat:direction], @"translationX",
                                  [NSNumber numberWithFloat:0], @"translationY",
                                  [NSNumber numberWithBool:YES], @"isMovingHorizontally",
                                  [NSNumber numberWithInt:touchPosition.row], @"positionX",
                                  [NSNumber numberWithInt:touchPosition.column], @"positionY",
                                  nil];
            
            [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
            [NSThread sleepForTimeInterval:0.001];
        }
    }
    
    if(![[NSThread currentThread] isCancelled])
    {
        _lastTouchedPosition = DWPositionMake(-55, -55);
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

-(void)easeColumn:(NSDictionary *)params
{
    //return;
    CGPoint velocity = CGPointMake([[params objectForKey:@"VelocityX"] floatValue], [[params objectForKey:@"VelocityY"] floatValue]);
    DWPosition touchPosition = DWPositionMake([[params objectForKey:@"TouchRow"] floatValue], [[params objectForKey:@"TouchColumn"] floatValue]);
    
    CGFloat height = self.bounds.size.height;
    CGFloat rowHeight = height / _numberOfVisibleRowsInGrid;
    
    if( fabsf(velocity.y) < rowHeight)
    {
        if (velocity.y < 0 )
        {
            velocity.y = -rowHeight;
        }
        else
        {
            velocity.y = rowHeight;
        }
    }
    
    CGFloat direction = velocity.y / stepSize;
    if(velocity.y < 0) //moving up
    {
        int c = touchPosition.column;
        bool doExit = false;
        for(CGFloat i = 0; ![[NSThread currentThread] isCancelled]; i+=fabsf(direction))
        {
            doExit = false;
            if( i >= fabsf(velocity.y) - rowHeight)
            {
                //for(int c = -outerOffset; c < _numberOfVisibleColumnsInGrid+outerOffset; c++)
                //for(int c = 0; c< _numberOfVisibleColumnsInGrid; c++)
                {

                    DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:DWPositionMake(0, c)];
                    if ((int) roundf(cell.frame.origin.y) % (int) roundf(rowHeight) == 0) {
                        if (cell.frame.origin.y != 0) {
                            direction = cell.frame.origin.y - rowHeight;
                            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithFloat:velocity.y], @"velocity",
                                    [NSNumber numberWithBool:YES], @"reloadingData",
                                    [NSNumber numberWithFloat:0], @"translationX",
                                    [NSNumber numberWithFloat:direction], @"translationY",
                                    [NSNumber numberWithBool:NO], @"isMovingHorizontally",
                                    [NSNumber numberWithInt:0], @"positionX",
                                    [NSNumber numberWithInt:c], @"positionY",
                                            nil];
                            [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
                        }
                        doExit = true;
                        break;
                    }
                }
            }

            direction = (velocity.y + i) / stepSize;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithFloat:velocity.y], @"velocity",
                    [NSNumber numberWithBool:YES], @"reloadingData",
                    [NSNumber numberWithFloat:0], @"translationX",
                    [NSNumber numberWithFloat:direction], @"translationY",
                    [NSNumber numberWithBool:NO], @"isMovingHorizontally",
                    [NSNumber numberWithInt:touchPosition.row], @"positionX",
                    [NSNumber numberWithInt:c], @"positionY",
                            nil];
            [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
            //if (doExit)
            //    break;

            [NSThread sleepForTimeInterval:0.001];
        }
    }
    else //moving down
    {
        int c = touchPosition.column;
        bool doExit = false;
        for(CGFloat i = 0; ![[NSThread currentThread] isCancelled]; i+=fabsf(direction))
        {
            doExit = false;
            if( i >= fabsf(velocity.y) - rowHeight)
            {
                //for(int c = -outerOffset; c < _numberOfVisibleColumnsInGrid+outerOffset; c++)
                {
                    DWGridViewCell *cell = [self.delegate gridView:self cellAtPosition:DWPositionMake(0, c)];
                    if((int)roundf(cell.frame.origin.y) % (int)roundf(rowHeight) == 0)
                    {
                        if(cell.frame.origin.y != 0)
                        {
                            direction = rowHeight - cell.frame.origin.y;
                            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithFloat:velocity.y], @"velocity",
                                                  [NSNumber numberWithBool:YES], @"reloadingData",
                                                  [NSNumber numberWithFloat:0], @"translationX",
                                                  [NSNumber numberWithFloat:direction], @"translationY",
                                                  [NSNumber numberWithBool:NO], @"isMovingHorizontally",
                                                  [NSNumber numberWithInt:0], @"positionX",
                                                  [NSNumber numberWithInt:c], @"positionY",
                                                  nil];
                            [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];
                        }
                        doExit = true;
                        break;
                    }
                }
            }


            direction = (velocity.y - i) / stepSize;
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithFloat:velocity.y], @"velocity",
                          [NSNumber numberWithBool:YES], @"reloadingData",
                          [NSNumber numberWithFloat:0], @"translationX",
                          [NSNumber numberWithFloat:direction], @"translationY",
                          [NSNumber numberWithBool:NO], @"isMovingHorizontally",
                          [NSNumber numberWithInt:touchPosition.row], @"positionX",
                          [NSNumber numberWithInt:c], @"positionY",
                          nil];
            [self performSelectorOnMainThread:@selector(moveCellSelector:) withObject:dict waitUntilDone:YES];

            //if (doExit)
            //    break;
            [NSThread sleepForTimeInterval:0.001];
            
        }
    }
    
    if(![[NSThread currentThread] isCancelled])
    {
        _lastTouchedPosition = DWPositionMake(-55, -55);
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

-(void)easeOut:(NSTimer *)timer
{
    if(_isMovingHorizontally)
    {
        _easeThread = [[NSThread alloc] initWithTarget:self selector:@selector(easeRow:) object:timer.userInfo];
        [_easeThread start];
    }
    else
    {
        _easeThread = [[NSThread alloc] initWithTarget:self selector:@selector(easeColumn:) object:timer.userInfo];
        [_easeThread start];
    }
    _easeOutTimer = nil;
}

-(void)moveCellAtPosition:(DWPosition)position horizontallyBy:(CGFloat)velocity withTranslation:(CGPoint)translation reloadingData:(BOOL)shouldReload
{
    for(int i = -outerOffset; i< _numberOfVisibleColumnsInGrid+outerOffset; i++)
    {
        UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(position.row, i)]];
        
        CGPoint center = cell.center;
        center.x += translation.x;
        cell.center = center;
    }
    
    UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(position.row, 0)]];
    CGFloat width = self.bounds.size.width;
    CGFloat columnWidth = width / _numberOfVisibleColumnsInGrid;
    CGFloat posX = cell.frame.origin.x;
    if(posX >= columnWidth)
    {
        [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(position.row, position.column +1)];
        if(shouldReload)
        {
            [self reloadData];
        }
    }
    else if(posX <= 0-columnWidth)
    {
        [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(position.row, position.column -1)];
        if(shouldReload)
        {
            [self reloadData];
        }
    }
}

-(void)moveCellAtPosition:(DWPosition)position verticallyBy:(CGFloat)velocity withTranslation:(CGPoint)translation reloadingData:(BOOL)shouldReload
{
    for(int i = -outerOffset; i< _numberOfVisibleRowsInGrid+outerOffset; i++)
    {
        UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(i, position.column)]];
        CGPoint center = cell.center;
        center.y += translation.y;
        cell.center = center;
    }
    
    UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(0, position.column)]];
    CGFloat height = self.bounds.size.height;
    CGFloat rowHeight = height / _numberOfVisibleRowsInGrid;
    CGFloat posY = cell.frame.origin.y;
    if(posY >= rowHeight)
    {

        [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(position.row +1, position.column)];
        if(shouldReload)
        {
            [self reloadData];
        }
    }else if(posY <= 0-rowHeight)
    {

        [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(position.row -1, position.column)];
        if(shouldReload)
        {
            [self reloadData];
        }
    }

}


-(void)moveRowAtPosition:(DWPosition)position verticallyBy:(CGFloat)velocity withTranslation:(CGPoint)translation reloadingData:(BOOL)shouldReload
{
    for(int i = -outerOffset; i< _numberOfVisibleRowsInGrid+outerOffset; i++)
    {
        for(int c = 0; c< _numberOfVisibleColumnsInGrid; c++)
        {
            UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(i, c)]];
            CGPoint center = cell.center;
            center.y += translation.y;
            cell.center = center;
        }
    }
    
    for(int c = -outerOffset; c< _numberOfVisibleColumnsInGrid+outerOffset; c++)
    {
        UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(0, c)]];
        CGFloat height = self.bounds.size.height;
        CGFloat rowHeight = height / _numberOfVisibleRowsInGrid;
        CGFloat posY = cell.frame.origin.y;
        if(posY >= rowHeight)
        {
            [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(position.row +1, c)];
            if(shouldReload)
            {
                [self reloadData];
            }
        }else if(posY <= 0-rowHeight)
        {
            [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(position.row -1, c)];
            if(shouldReload)
            {
                [self reloadData];
            }
        }
    }
}


-(void)moveColumnAtPosition:(DWPosition)position horizontallyBy:(CGFloat)velocity withTranslation:(CGPoint)translation reloadingData:(BOOL)shouldReload
{
    for(int i = -outerOffset; i< _numberOfVisibleColumnsInGrid+outerOffset; i++)
    {
        UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(position.row, i)]];

        CGPoint center = cell.center;
        center.x += translation.x;
        cell.center = center;
    }
    for(int r = -outerOffset; r< _numberOfVisibleRowsInGrid+outerOffset; r++) {

        UIView *cell = [self viewWithTag:[self tagForPosition:DWPositionMake(r, 0)]];
        CGFloat width = self.bounds.size.width;
        CGFloat columnWidth = width / _numberOfVisibleColumnsInGrid;
        CGFloat posX = cell.frame.origin.x;
        if (posX >= columnWidth) {
            [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(r, position.column + 1)];
            if (shouldReload) {
                [self reloadData];
            }
        }
        else if (posX <= 0 - columnWidth) {
            [self.delegate gridView:self didMoveCell:[self.delegate gridView:self cellAtPosition:position] fromPosition:position toPosition:DWPositionMake(r, position.column - 1)];
            if (shouldReload) {
                [self reloadData];
            }
        }
    }
}

-(NSArray *)visibleCells
{
    NSMutableArray *visibleCells = [[NSMutableArray alloc] init];
    for(UIView *v in self.subviews)
    {
        if([v isKindOfClass:[DWGridViewCell class]] && CGRectIntersectsRect(v.frame, self.bounds))
        {
            [visibleCells addObject:v];
        }
    }
    return [NSArray arrayWithArray:visibleCells];
}
@end