#import "idfunctions.h"
#import <appkit/appkit.h>
#import "EditWorld.h"


#define	SPACING				10

@interface TextureEdit:Object
{
	id	window_i;
	id	textureView_i;
	id	texturePatchWidthField_i;
	id	texturePatchHeightField_i;
	id	texturePatchNameField_i;
	id	textureWidthField_i;
	id	textureHeightField_i;
	id	textureNameField_i;
	id	patchWidthField_i;
	id	patchHeightField_i;
	id	patchNameField_i;
	id	scrollView_i;
	id	outlinePatches_i;
	id	lockedPatch_i;
	id	centerPatch_i;
	id	texturePatchScrollView_i;
	id	texturePatchView_i;
	id	createTexture_i;
	id	createWidth_i;
	id	createHeight_i;
	id	createName_i;
	id	createDone_i;

	id	patchImages;
	
	int	selectedPatch;		// in the Patch Palette
	int	currentPatch;			// in the Texture Editor View
	int	currentTexture;		// being edited
	int	oldx,oldy;
}

typedef struct
{
	int	sel;
} store_t;

// a patch holds one or more collumns
// Some patches will be in native color, while be used with a color remap table
typedef struct
{
	byte		width;			// bounding box size
	byte		height;
	char		leftoffset;			// pixels to the left of origin
	char		bottomoffset;		// pixels below the origin
	short	collumnofs[256];	// only [width] used, the [0] is &collumnofs[width]
} patch_t;

typedef struct
{
	byte		topdelta;			// -1 is the last post in a collumn
	byte		length;
// length data bytes follow
} post_t;

// collumn_t is a list of 0 or more post_t, (byte)-1 terminated
typedef post_t	collumn_t;

//
// structure for loaded patches
//
typedef struct
{
	NXRect	r;
	id		image;
	id		image_x2;
} apatch_t;

typedef	struct
{
	int	patchLocked;
	NXRect	r;
	worldpatch_t	patchInfo;
	apatch_t		*patch;
} texpatch_t;



extern	id	texturePatches;
extern	id	textureEdit_i;

- changedWidth:sender;
- changedHeight:sender;
- changedTitle:sender;
- setOldVars:(int)x :(int)y;
- doLockToggle;
- togglePatchLock:sender;
- deleteCurrentPatch:sender;
- sortUp:sender;
- sortDown:sender;
- setCurrentEditPatch:(int)which;
- (int)getCurrentEditPatch;
- outlineWasSet:sender;
- (apatch_t *)getPatch:(int)which;
- (apatch_t *)getPatchImage:(char *)name;
- finishTexture:sender;
- addPatch:(int)which;
- sizeChanged:sender;
- fillWithPatch:sender;
- menuTarget:sender;
- (int)getCurrentTexture;
- (int)getCurrentPatch;
- makeNewTexture:sender;
- createTextureDone:sender;
- createTextureAbort:sender;
- newSelection:(int)which;
- setSelectedPatch:(int)which;
- (int)getOutlineFlag;
- initPatches;
- menuTarget:sender;
- computePatchDocView: (NXRect *)theframe;

@end

id	patchToImage(patch_t *patchData,byte const *lbmpalette,NXSize *size);
char *strupr(char *string);
