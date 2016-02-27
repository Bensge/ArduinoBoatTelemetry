//
//  TCStatusLabel.m
//  TelemetryCenter
//
//  Created by Benno Krauss on 02/01/16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

#import "TCStatusLabel.h"

@implementation TCStatusLabel

void commonInit(TCStatusLabel *self, SEL _cmd)
{
	self.textAlignment = NSTextAlignmentCenter;
	self.font = self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? [UIFont boldSystemFontOfSize:14] : [UIFont boldSystemFontOfSize:18];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		commonInit(self, _cmd);
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		commonInit(self,_cmd);
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:1];
	CGRect backgroundRect = CGRectInset(CGRectMake(self.frame.size.width / 2 - textRect.size.width / 2, self.frame.size.height / 2 - textRect.size.height / 2, textRect.size.width, textRect.size.height),-5,-5);
	
	[self.tintColor setFill];
	//[UIColor.blackColor setFill];
	[[UIBezierPath bezierPathWithRoundedRect:backgroundRect cornerRadius:5] fill];
	
	[super drawRect:rect];
}

- (void)tintColorDidChange
{
	[super tintColorDidChange];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	commonInit(self, _cmd);
}

- (void)prepareForInterfaceBuilder
{
	commonInit(self, _cmd);
}

@end
