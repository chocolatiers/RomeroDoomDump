
#import <appkit/appkit.h>

#define	SPACING				10
#define	PLANEWINDOWX			100
#define	PLANEWINDOWY			0
#define	PLANEWINDOWWIDTH	(64 + SPACING)*3 + SPACING
#define	PLANEWINDOWHEIGHT	400

@interface PlaneWindow:Window
{
	id	planeScrollView_i;
	id	planeDocView_i;
	NXRect	curWindowRect;
}

- (int)currentViewSelection;
- computePlaneDocView: (NXRect *)frame;

@end
