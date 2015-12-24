//
//  ViewController.m
//  CHess
//
//  Created by Admin on 10.12.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *chessTiles;
@property (strong, nonatomic) NSMutableArray *chessCheckers;
@property (strong, nonatomic) NSMutableArray *tilesBoolean;
@property (strong, nonatomic) UIImageView *chessBoardPattern;
@property (weak, nonatomic) UIView *draggingView;
@property (assign, nonatomic) CGPoint touchOffset;
@property (assign, nonatomic) CGPoint firstTouchTileCenter;
@property (assign, nonatomic) float height;

@end

@implementation ViewController

#pragma mark - viewDidLoad & didRotateFromInterfaceOrientation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // Board
    
    if (CGRectGetHeight(self.view.bounds) < CGRectGetWidth(self.view.bounds)) {
        self.height = CGRectGetHeight(self.view.bounds);
        
    } else {
        self.height = CGRectGetWidth(self.view.bounds);
    }
    
    self.chessBoardPattern = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.height, self.height)];
    [self.view addSubview:self.chessBoardPattern];
    self.chessBoardPattern.userInteractionEnabled = YES;
    self.chessBoardPattern.center = self.chessBoardPattern.superview.center;
    self.chessBoardPattern.image = [UIImage imageNamed:@"2.jpg"];
    self.chessBoardPattern.autoresizingMask =   UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleTopMargin;
    
    // Tiles and checkers
    
    self.chessTiles = [NSMutableArray new];
    self.chessCheckers = [NSMutableArray new];
    self.tilesBoolean = [NSMutableArray new];
    self.height = self.height / 8;
    int i = 1;
    
    for (int x = 1; x <= 8; x++) {
        
        for (int y = 1; y <= 8; y++) {
            
            if (!((x+y)%2)) {
                
                UIView *tile = [[UIView alloc] initWithFrame:CGRectMake(x * self.height - self.height, y * self.height - self.height, self.height, self.height)];
                tile.backgroundColor = [UIColor blackColor];
                tile.tag = i;
                [self.chessBoardPattern addSubview:tile];
                [self.chessTiles addObject:tile];
                
                if (y <= 2) {
                    UIView* checker = [self makeCheckerWithX:x andY:y andColor:@"white"];
                    checker.userInteractionEnabled = YES;
                    // checker.backgroundColor = [UIColor cyanColor];
                }
                
                if (y >= 7) {
                    UIView* checker = [self makeCheckerWithX:x andY:y andColor:@"black"];
                    checker.userInteractionEnabled = YES;
                    
                    // checker.backgroundColor = [UIColor  whiteColor];
                }
                
                if ((y > 2) & (y < 7)) {
                    [self.tilesBoolean addObject:[NSNumber numberWithBool:0]];
                } else {
                    [self.tilesBoolean addObject:[NSNumber numberWithBool:1]];
                }
                
                i++;
            }
        }
    }
    
    for (UIView *checker in self.chessCheckers) {
        [self.chessBoardPattern bringSubviewToFront:checker];
    }
    
    self.height = self.height / 2;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    self.chessBoardPattern.center = self.chessBoardPattern.superview.center;
    
    for (int i = 0; i < 32; i++) {
        self.tilesBoolean[i] = [NSNumber numberWithBool:0];
    }
    
    // Checkers shuffle
    
    NSMutableSet* SetOfFullTiles = [NSMutableSet new];
    BOOL tileIsFull = NO;
    int i = arc4random()%32;
    
    for (UIView* checker in self.chessCheckers) {
        while (tileIsFull == YES) {
            
            i = arc4random()%32;
            
            if ([SetOfFullTiles containsObject:[NSNumber numberWithInt:i]]) {
                tileIsFull = YES;
            } else {
                tileIsFull = NO;
            }
        }
        
        if ([self.chessTiles[i] isKindOfClass:[UIView class]]) {
            checker.center = ((UIView *)[self.chessTiles objectAtIndex:i]).center;
            self.tilesBoolean[i] = [NSNumber numberWithBool:1];
        } else {
            NSLog (@"Error 404");
        }
        
        [SetOfFullTiles addObject:[NSNumber numberWithInt:i]];
        tileIsFull = YES;
        
    }
    
    NSLog(@"Shuffle is done.");
}


#pragma mark - Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    UIView *view = [self.view hitTest:[touch locationInView:self.view] withEvent:event];
    
    // Setting dragging view
    
    if (view.tag == 50) {                           // Checkers tag is 50.
        
        self.draggingView = view;
        [self scaleViewOnTouch:self.draggingView];
        
        CGPoint touchPoint = [touch locationInView:view];
        self.touchOffset =   CGPointMake(CGRectGetMidX(self.draggingView.bounds) - touchPoint.x,
                                         CGRectGetMidY(self.draggingView.bounds) - touchPoint.y);
        
        self.firstTouchTileCenter = view.center;
        
    } else {
        self.draggingView = nil;
    }
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.chessBoardPattern];
    
    // Moving dragging view
    
    if (self.draggingView) {
        
        CGPoint correction = CGPointMake (touchPoint.x + self.touchOffset.x, touchPoint.y + self.touchOffset.y);
        self.draggingView.center = correction;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    // Dragging view interaction on touch end
    
    [self scaleViewOnTouchEnd:self.draggingView];
    
    if (self.draggingView) {
        
        int i = 0;
        
        for (UIView *tile in self.chessTiles) {
            
            if  ([tile pointInside:[touch locationInView:tile] withEvent:event]) {
                
                if (self.tilesBoolean[i] == [NSNumber numberWithBool:0]) {
                    
                    self.draggingView.center = tile.center;
                    self.tilesBoolean[i] = [NSNumber numberWithBool:1];
                    long tag = [self emptyStartingTileGetTag];
                    NSLog(@"Checker has been moved from %ld to %d tile.", (long)tag, i + 1);
                    
                    break;
                    
                } else {
                    [self returnViewOnTouchCancel];
                    NSLog(@"Can't move here, this tile is full.");
                }
                
            } else {
                i++;
            }
            
            if (i == 32) {
                [self returnViewOnTouchCancel];
                NSLog(@"Please choose an empty black tile.");
            }
        }
    }
    self.draggingView = nil;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self scaleViewOnTouchEnd:self.draggingView];
    [self returnViewOnTouchCancel];
    self.draggingView = nil;
}

- (void) touchesSet:(NSSet *)touches withMethod:(NSString *)methodName {
    
    NSMutableString *string = [NSMutableString stringWithString:methodName];
    
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self.chessBoardPattern];
        [string appendFormat: @" %@ ", NSStringFromCGPoint(touchPoint)];
    }
    
    NSLog(@"%@", string);
}

#pragma mark - Private methods

- (UIView *) makeCheckerWithX:(float)x andY:(float)y andColor:(NSString*)color {
    
    //    UIView* checker = [[UIView alloc] initWithFrame:CGRectMake (x * self.height - self.height * 0.75, y * self.height - self.height * 0.75, self.height/2, self.height/2)];
    
    CGRect frame = CGRectMake (x * self.height - self.height* 0.875, y * self.height - self.height * 0.875, self.height* 0.75, self.height * 0.75);
    
    NSString *colorString = [NSString stringWithFormat:@"%@Checker-2.png", color];
    UIImageView *checker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:colorString]];
    checker.frame = frame;
    checker.contentMode = UIViewContentModeScaleAspectFill;
    [self.chessBoardPattern addSubview:checker];
    [self.chessCheckers addObject:checker];
    checker.tag = 50;
    //checker.layer.cornerRadius = 16;
    return checker;
}

- (float) randomFrom0To1 {
    return (float)(arc4random_uniform(256)) / 255;
}

- (UIColor*) randomColor {
    
    float r = [self randomFrom0To1];
    float g = [self randomFrom0To1];
    float b = [self randomFrom0To1];
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}


- (void) scaleViewOnTouch:(UIView *)view {
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGAffineTransform scale = CGAffineTransformMakeScale(1.7f, 1.7f);
                         view.transform = scale;
                         view.alpha = 0.7f;
                     }];
}


- (void) scaleViewOnTouchEnd:(UIView *)view {
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.transform = CGAffineTransformIdentity;
                         view.alpha = 1;
                         
                     }];
}

- (void) returnViewOnTouchCancel {
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.draggingView.center = self.firstTouchTileCenter;
                     }];
}

- (long) emptyStartingTileGetTag {
    
    long tag = 0;
    
    for (UIView *tile in self.chessTiles) {
        
        if (CGRectContainsPoint(tile.frame, self.firstTouchTileCenter)) {
            self.tilesBoolean[tile.tag - 1] = [NSNumber numberWithBool:0];
            tag = tile.tag;
            
            break;
        }
    }
    return tag;
}

- (void) finishTileFull:(int)i {
    self.tilesBoolean[i] = [NSNumber numberWithBool:1];
}

#pragma mark - OtherMethods

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return  UIInterfaceOrientationMaskLandscapeLeft |
    UIInterfaceOrientationMaskLandscapeRight|
    UIInterfaceOrientationMaskPortrait |
    UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
