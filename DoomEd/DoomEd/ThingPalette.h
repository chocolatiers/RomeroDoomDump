
#import <appkit/appkit.h>

typedef struct
{
	NXRect	r;
	NXSize	imagesize;
	char	name[10];
	id		image;
} icon_t;

#define	SPACING		10
#define	ICONSIZE	48

extern id	thingPalette_i;

@interface ThingPalette:Object
{
	id		window_i;			// outlet
	id		thingPalView_i;		// outlet
	id		thingPalScrView_i;	// outlet
	id		nameField_i;		// outlet
	
	id		thingImages;		// Storage for icons
	int		currentIcon;		// currently selected icon
}

- menuTarget:sender;
- (int)findIcon:(char *)name;
- (icon_t *)getIcon:(int)which;
- (int)getCurrentIcon;
- setCurrentIcon:(int)which;
- (int)getNumIcons;
- computeThingDocView;
- initIcons;
- dumpAllIcons;


@end
