#import	"DoomProject.h"
#import	"idfunctions.h"
#import <appkit/appkit.h>

typedef struct
{
	id	image;
	char		name[9];
	NXRect	r;
} flat_t;

typedef struct
{
	worldends_t	w;
	id	image;
	NXRect	r;
	int	floor_flat,ceiling_flat;
} sector_t;

#define	SPACING	10

extern id	sectorEdit_i;

@interface SectorEditor:Object
{
	id	window_i;
	id	sectorEditView_i;
	id	flatScrPalView_i;
	id	flatPalView_i;
	id	sectorPalette_i;
	
	id	lightLevel_i;
	id	special_i;
	id	floorAndCeiling_i;
	id	ceiling_i;
	id	floor_i;
	id	title_i;
	id	cheightfield_i;
	id	fheightfield_i;
	
	id	flatImages;
	int	currentFlat;
}

- changeSector:(int) which;
- selectFloor;
- selectCeiling;
- setSectorTitle:(char *)string;
- setCeiling:(int) what;
- setFloor:(int) what;
- titleChanged:sender;
- CorFheightChanged:sender;
- (int) getNumFlats;
- (char *)flatName:(int) flat;
- (flat_t *) getFlat:(int) which;
- selectFlat:(int) which;
- (int) getCurrentFlat;
- (int) getLight;
- (int) getSpecial;
- menuTarget:sender;
- (int)loadFlats;
- createSector:sender;
- saveSector:sender;
- computeFlatDocView;
- (int) findFlat:(const char *)name;
- addToPalette:sender;
- error:(const char *)string;

@end

id	flatToImage(byte *rawData,byte const *lbmpalette);
