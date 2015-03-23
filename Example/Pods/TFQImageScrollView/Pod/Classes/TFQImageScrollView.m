//
//  TFQImageScrollView.m
//  CBNClient
//
//  Created by cbn_tech on 14-6-30.
//  Copyright (c) 2014年 TFQ. All rights reserved.
//

#import "TFQImageScrollView.h"
#import "UIImageView+WebCache.h"

#define kHeadlineSize [self.imageScrollViewDatasource numberOfImageScrollView:self]

#define kImageWidth self.imageSize.width
@interface TFQImageScrollView()<UIScrollViewDelegate>{
    NSInteger _page;
}
@property (strong,nonatomic) NSArray*imageViews;
@end
@implementation TFQImageScrollView
- (NSArray*)imageViews{
    if (!_imageViews) {
        NSMutableArray*temp=[[NSMutableArray alloc] initWithCapacity:3];
        for (int i=0; i<3; i++) {
            UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake( self.frame.size.width*i-self.frame.size.width,0,  self.frame.size.width, self.frame.size.height)];
            [temp addObject:imageView];
            [self addSubview:imageView];
        }
        _imageViews=[NSArray arrayWithArray:temp];
    }
    return _imageViews;
}
-(void)layoutSubviews{
    self.delegate=self;
    self.pagingEnabled=YES;
    self.bounces=NO;
    self.showsHorizontalScrollIndicator=NO;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headlineDidselected)]];
}
-(CGSize)imageSize{
    UIView*view= [self.imageViews objectAtIndex:0];
    return  view.frame.size;
}
-(void)setImageSize:(CGSize)imageSize{
    for (int i=0; i<3; i++) {
        UIView*view= [self.imageViews objectAtIndex:i];
        CGRect frame=CGRectZero;
        frame.size = imageSize;
        frame.origin.x=(i-1)*imageSize.width;
        view.frame=frame;
    }
    self.contentInset=UIEdgeInsetsMake(0, imageSize.width, 0,imageSize.width*2);


}

-(void)headlineDidselected{
    if (kHeadlineSize) {
        if ([self.imageScrollViewDelegate respondsToSelector:@selector(imageScrollView:didSelectedAtIndex:)]) {
            [self.imageScrollViewDelegate imageScrollView:self didSelectedAtIndex:_page];
        }
    }
    
}
-(void)setImageScrollViewDatasource:(id<TFQImageScrollViewDatasource>)imageScrollViewDatasource{
    _imageScrollViewDatasource=imageScrollViewDatasource;
    
    _page=0;
    
    if(kHeadlineSize){
        
        [self reloadImages];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(kHeadlineSize){
        NSInteger i=scrollView.contentOffset.x/kImageWidth;
        if (i) {
            _page=(kHeadlineSize+_page+i)%kHeadlineSize;

            [self reloadImages];
            [self setContentOffset:CGPointMake(0, 0) animated:NO];

            if ([self.imageScrollViewDelegate respondsToSelector:@selector(imageScrollView:didEndScrolltoIndex:)]) {
                [self.imageScrollViewDelegate imageScrollView:self didEndScrolltoIndex:_page];
            }
        }
    }
}
-(void)reloadImages{
    if (kHeadlineSize>0){
        for (int i=0; i<3; i++) {
            
            NSString*url=[self.imageScrollViewDatasource imageScrollView:self imageUrlAtIndex:(kHeadlineSize+_page+i-1)%kHeadlineSize];
            [[self.imageViews objectAtIndex:i] setImageWithURL:[NSURL URLWithString:url]];

        }

    }
}
-(void)nextImage{
    [super setContentOffset:CGPointMake(self.frame.size.width, 0) animated:YES];
    [self performSelector:@selector(nextImageAfterDelay) withObject:nil afterDelay:0.25];
   
}
-(void)nextImageAfterDelay{
    _page=(kHeadlineSize+_page+1)%kHeadlineSize;
    
    [self reloadImages];
    [self setContentOffset:CGPointMake(0, 0) animated:NO];
    if ([self.imageScrollViewDelegate respondsToSelector:@selector(imageScrollView:didEndScrolltoIndex:)]) {
        [self.imageScrollViewDelegate imageScrollView:self didEndScrolltoIndex:_page];
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
