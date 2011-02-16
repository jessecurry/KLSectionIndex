//
//  KLSectionIndex.m
//  Keylime
//
//  Created by Jesse Curry on 1/25/11.
//  Copyright 2011 Circonda, Inc. All rights reserved.
//

#import "KLSectionIndex.h"
#import <QuartzCore/QuartzCore.h>

static const NSTimeInterval kTransitionDuration = 0.2;
static const NSInteger kTextLabelTag = 9989;

#define INDEX_LABEL_TEXT_COLOR [UIColor colorWithWhite: 1.0 alpha: 1.0]
#define DEFAULT_COLOR [UIColor clearColor]
#define HIGHLIGHT_COLOR [UIColor colorWithWhite: 0.6 alpha: 0.55]

@interface KLSectionIndex ()
@property (nonatomic, retain) NSString* sectionIndexString;
- (void)reloadSectionIndexString;
- (void)refreshView;
- (void)transitionToBackgroundColor: (UIColor*)color;
- (void)calculateSelectedSectionIndexForTouch: (UITouch*)touch;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation KLSectionIndex
@synthesize sectionIndexTitles;
@synthesize sectionIndexString;

- (id)initWithFrame: (CGRect)frame
{
	if ( self = [super initWithFrame: frame] )
	{
		self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
		self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
		self.layer.cornerRadius = self.frame.size.width / 2.0;
		self.clipsToBounds = YES;
		selectedIndex = KLSectionIndexSelectionNone;
	}
	return self;
}

- (void)dealloc
{
	[sectionIndexTitles release];
	[sectionIndexString release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Properties
- (void)setSectionIndexTitles: (NSArray*)newSectionIndexTitles
{
	if ( sectionIndexTitles != newSectionIndexTitles )
	{
		[sectionIndexTitles release];
		sectionIndexTitles = newSectionIndexTitles;
		[sectionIndexTitles retain];
		
		[self reloadSectionIndexString];
		[self refreshView];
	}
}

- (NSInteger)selectedIndex
{
	return selectedIndex;
}

- (NSString*)selectedIndexTitle
{
	if ( selectedIndex >= 0 && selectedIndex < [self.sectionIndexTitles count] )
	{
		return [self.sectionIndexTitles objectAtIndex: selectedIndex];
	}
	else
	{
		return nil;
	}
}

#pragma mark -
#pragma mark UIControl Overrides
- (BOOL)beginTrackingWithTouch: (UITouch*)touch withEvent: (UIEvent*)event
{
	// Set Highlight
	[self transitionToBackgroundColor: HIGHLIGHT_COLOR];
	
	[self calculateSelectedSectionIndexForTouch: touch];
	[self sendActionsForControlEvents: UIControlEventValueChanged];
	
	return [super beginTrackingWithTouch: touch withEvent: event];
}

- (BOOL)continueTrackingWithTouch: (UITouch*)touch withEvent: (UIEvent*)event
{
	[self calculateSelectedSectionIndexForTouch: touch];
	[self sendActionsForControlEvents: UIControlEventValueChanged];
	
	return [super continueTrackingWithTouch: touch withEvent: event];
}

- (void)endTrackingWithTouch: (UITouch*)touch withEvent: (UIEvent*)event
{
	// Flag the selected index as none.
	selectedIndex = KLSectionIndexSelectionNone;
	
	// Remove Highlight
	[self transitionToBackgroundColor: DEFAULT_COLOR];
}

#pragma mark -
#pragma mark Private
- (void)reloadSectionIndexString
{
	NSString* sis = nil;
	for ( NSString* s in sectionIndexTitles )
	{
		if ( sis == nil )
		{
			sis = s;
		}
		else
		{
			sis = [sis stringByAppendingFormat: @"\n%@", [s length] ? [s substringToIndex: 1] : @"•"];
		}
	}
	
	self.sectionIndexString = sis;
}

- (void)refreshView
{	
	// TODO: Reuse old views
	
	// Remove old view
	for ( UIView* v in self.subviews )
	{
		[v removeFromSuperview];
	}
	
	// Setup the offsets
	const CGFloat kLabelHeight = 14.0;
	CGFloat labelOffset = [self.sectionIndexTitles count] 
	? self.bounds.size.height / [self.sectionIndexTitles count]
	: (self.bounds.size.height / 2) - (kLabelHeight / 2);
	
	// Add new views for the section index labels
	for ( int i = 0; i < [self.sectionIndexTitles count]; ++i )
	{
		CGRect labelFrame = CGRectMake(0, 
									   (labelOffset/4.0) + (labelOffset * i), 
									   self.bounds.size.width, 
									   kLabelHeight);
		
		UILabel* sectionIndexLabel = [[UILabel alloc] initWithFrame: labelFrame];
		sectionIndexLabel.numberOfLines = 1;
		sectionIndexLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		sectionIndexLabel.textAlignment = UITextAlignmentCenter;
		sectionIndexLabel.textColor = INDEX_LABEL_TEXT_COLOR;
		sectionIndexLabel.font = [UIFont boldSystemFontOfSize: 12.0];
		sectionIndexLabel.backgroundColor = [UIColor clearColor];
		sectionIndexLabel.tag = kTextLabelTag;
		[self addSubview: sectionIndexLabel];
		[sectionIndexLabel release];
		
		NSString* s = [self.sectionIndexTitles objectAtIndex: i];
		sectionIndexLabel.text = [s length] ? [s substringToIndex: 1] : @"•";
	}
}

- (void)transitionToBackgroundColor: (UIColor*)color
{
	CATransition* transition = [CATransition animation];
	transition.duration = kTransitionDuration;
	transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	transition.delegate = nil;
	transition.type = kCATransitionFade;
	[self.layer addAnimation: transition forKey: nil];
	
	self.backgroundColor = color;
}

- (void)calculateSelectedSectionIndexForTouch: (UITouch*)touch
{
	CGPoint tp = [touch locationInView: self];
	selectedIndex = MIN(MAX(0, [self.sectionIndexTitles count] * (tp.y / self.frame.size.height)), [self.sectionIndexTitles count] - 1);
	
	//NSLog(@"%.2f/%.2f - selectedIndex = %d", tp.y, self.frame.size.height, selectedIndex );
}

@end
