#import	"DoomProject.h"
#import	"idfunctions.h"
#import <appkit/appkit.h>

typedef struct
{
	id		image;
	char	name[9];
	NXRect	r;
	int		WADindex;
} flat_t;

#define	SPACING		10
#define	FLATSIZE	64

extern id	sectorEdit_i;

@interface SectorEditor:Object
{
	id	window_i;
	id	sectorEditView_i;
	id	flatScrPalView_i;
	id	flatPalView_i;
	
	id	lightLevel_i;
	id	lightSlider_i;
	id	special_i;
	id	tag_i;
	id	floorAndCeiling_i;		// radio button matrix
	id	ceiling_i;				// radio button
	id	floor_i;				// radio button
	id	cheightfield_i;
	id	fheightfield_i;
	id	cflatname_i;
	id	fflatname_i;
	id	totalHeight_i;
	id	curFlat_i;
	
	int	ceiling_flat,floor_flat;
	sectordef_t	sector;
	
	id	flatImages;
	int	currentFlat;
	
	id	specialPanel_i;
}

- setKey:sender;
- setupEditor;
- pgmTarget;
- ceilingAdjust:sender;
- floorAdjust:sender;
- totalHeightAdjust:sender;
- getTagValue:sender;
- lightLevelDown:sender;
- lightLevelUp:sender;
- setSector:(sectordef_t *)s;
- (sectordef_t *) getSector;
- selectFloor;
- selectCeiling;
- lightChanged:sender;
- lightSliderChanged:sender;
- (flat_t *) getCeilingFlat;
- (flat_t *) getFloorFlat;
- setCeiling:(int) what;
- setFloor:(int) what;
- CorFheightChanged:sender;
- locateFlat:sender;
- (int) getNumFlats;
- (char *)flatName:(int) flat;
- (flat_t *) getFlat:(int) which;
- selectFlat:(int) which;
- setCurrentFlat:(int)which;
- (int) getCurrentFlat;
- menuTarget:sender;
- dumpAllFlats;
- emptySpecialList;
- (int)loadFlats;
- computeFlatDocView;
- (int) findFlat:(const char *)name;
- error:(const char *)string;
- saveFrame;

- searchForTaggedSector:sender;
- searchForTaggedLine:sender;

//
// sector special list
//
- activateSpecialList:sender;
- updateSectorSpecialsDSP:(FILE *)stream;
@end

id	flatToImage(byte *rawData, unsigned short *shortpal);
