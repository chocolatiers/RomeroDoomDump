#import "FloatingPanel.h"

@implementation FloatingPanel

- initContent:(const NXRect *)contentRect
style:(int)aStyle
backing:(int)bufferingType
buttonMask:(int)mask
defer:(BOOL)flag
{
	[super
		initContent:	contentRect
		style:		aStyle
		backing:		bufferingType
		buttonMask:	mask
		defer:		flag
	];
	
	[self setFloatingPanel: YES];
	
	return self;
}

#if 0
- (BOOL)canBecomeKeyWindow
{
	return NO;
}
#endif

- (BOOL)canBecomeMainWindow
{
	return NO;
}

@end

