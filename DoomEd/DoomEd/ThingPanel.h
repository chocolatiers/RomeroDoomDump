
#import <appkit/appkit.h>
#import 	"DoomProject.h"
#import		"EditWorld.h"

extern	id	thingpanel_i;

typedef struct
{
	char		name[32];
	char		iconname[9];
	NXColor	color;
	int		value, option,angle;
} thinglist_t;

#define	THINGNAME	"ThingInspector"

#define	DIFF_EASY	0
#define DIFF_NORMAL	1
#define DIFF_HARD	2
#define DIFF_ALL	3

@interface ThingPanel:Object
{
	id	fields_i;
 	id	window_i;
	id	addButton_i;
	id	updateButton_i;
	id	nameField_i;
	id	thingBrowser_i;
	id	thingColor_i;
	id	thingAngle_i;
	id	masterList_i;
	id	iconField_i;
	id	ambush_i;		// switch
	id	network_i;		// switch
	id	difficulty_i;	// switch matrix
	id	diffDisplay_i;	// radio matrix
	id	count_i;		// display count
	
	int	diffDisplay;
	
	worldthing_t	basething, oldthing;
}

- changeDifficultyDisplay:sender;
- (int)getDifficultyDisplay;
- emptyThingList;
- pgmTarget;
- menuTarget:sender;
- saveFrame;
- formTarget: sender;
- updateInspector: (BOOL)force;
- updateThingInspector;
- updateThingData:sender;
- sortThings;
- setAngle:sender;
- (NXColor)getThingColor:(int)type;
- fillThingData:(thinglist_t *)thing;
- fillDataFromThing:(thinglist_t *)thing;
- fillAllDataFromThing:(thinglist_t *)thing;
- addThing:sender;
- (int)findThing:(char *)string;
- (thinglist_t *)getThingData:(int)index;
- chooseThing:sender;
- confirmCorrectNameEntry:sender;
- getThing:(worldthing_t	*)thing;
- setThing:(worldthing_t *)thing;
- (int)searchForThingType:(int)type;
- suggestNewType:sender;
- scrollToItem:(int)which;
- getThingList;

- verifyIconName:sender;
- assignIcon:sender;
- unlinkIcon:sender;
- selectThingWithIcon:(char *)name;

- (thinglist_t *)getCurrentThingData;
- currentThingCount;

- (BOOL) readThing:(thinglist_t *)thing	from:(FILE *)stream;
- writeThing:(thinglist_t *)thing	from:(FILE *)stream;
- updateThingsDSP:(FILE *)stream;

@end
