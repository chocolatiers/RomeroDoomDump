
#import <appkit/appkit.h>

extern	id	prefpanel_i;

#define	APPDEFAULTS	"ID_doomed"
#define NUMCOLORS	9

typedef enum
{
	BACK_C = 0,
	GRID_C,
	TILE_C,
	SELECTED_C,
	POINT_C,
	ONESIDED_C,
	TWOSIDED_C,
	AREA_C,
	THING_C
} ucolor_e;

@interface PreferencePanel:Object
{
    id	backcolor_i;
    id	gridcolor_i;
    id	tilecolor_i;
    id	selectedcolor_i;
    id	pointcolor_i;
    id	onesidedcolor_i;
    id	twosidedcolor_i;
    id	areacolor_i;
    id thingcolor_i;
	
    id	window_i;
	
	id	colorwell[NUMCOLORS];
	NXColor	color[NUMCOLORS];
}

- menuTarget:sender;
- colorChanged:sender;

- appWillTerminate: sender;

- (NXColor)colorFor: (int)ucolor;

@end
