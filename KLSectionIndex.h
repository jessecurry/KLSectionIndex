//
//  KLSectionIndex.h
//  Keylime
//
//  Created by Jesse Curry on 1/25/11.
//  Copyright 2011 Circonda, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

enum KLSectionIndexSelection {
	KLSectionIndexSelectionNone = -1,
	KLSectionIndexSelectionCount
};

@interface KLSectionIndex : UIControl 
{
	NSArray*	sectionIndexTitles;
	NSString*	sectionIndexString;
	NSInteger	selectedIndex;
}
@property (nonatomic, retain) NSArray* sectionIndexTitles;
@property (nonatomic, readonly) NSInteger selectedIndex;
@property (nonatomic, readonly) NSString* selectedIndexTitle;

@end
