
#import <appkit/appkit.h>

extern	id	planePalette_i;

@interface PlanePalette:Object
{
	id	window_i;
	id	planeImages;
}

- (int) currentSelection;
- (apatch_t *) getPlane:(int)which;
- menuTarget:sender;

@end

id	planeToImage(byte *planeData,byte const *lbmpalette);
