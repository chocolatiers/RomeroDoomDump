
#import <appkit/appkit.h>

#define	PATCHWINDOWX			200
#define	PATCHWINDOWY			0
#define	PATCHWINDOWWIDTH	400
#define	PATCHWINDOWHEIGHT	400
#define	SPACING				10

@interface PatchWindow:Window
{
	id	patchScrollView_i;
	id	patchDocView_i;
	NXRect	curWindowRect;
}

- (int)currentViewSelection;
- computePatchDocView: (NXRect *)frame;

@end

