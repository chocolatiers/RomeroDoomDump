#import "idfunctions.h"
#import <appkit/appkit.h>
#import "EditWorld.h"
#import	"TexturePatchView.h"


#define	SPACING				10

@interface TextureEdit:Object
{
	id	window_i;				// Texture Editor window
	id	textureView_i;				// texture editing area
	id	texturePatchWidthField_i;	// under Patch Palette (information)
	id	texturePatchHeightField_i;	// . . .
	id	texturePatchNameField_i;
	id	texturePatchXField_i;
	id	texturePatchYField_i;
	id	textureWidthField_i;	// at top of window
	id	textureHeightField_i;	// . . .
	id	textureNameField_i;
	id	patchWidthField_i;		// under Patch Palette
	id	patchHeightField_i;		// . . .
	id	patchNameField_i;
	id	scrollView_i;			// texture editing area
	id	outlinePatches_i;		// switch
	id	lockedPatch_i;			// switch
	id	centerPatch_i;			// switch
	id	texturePatchScrollView_i;	// Patch Palette
	id	texturePatchView_i;		// Patch Palette
	id	dragWarning_i;			// warning for dragging selections outside
	id	splitView_i;			// NXSplitView!
	id	topView_i;
	id	botView_i;

	id	createTexture_i;		// Create Texture window
	id	createWidth_i;			// in Create Texture dialog
	id	createHeight_i;			// . . .
	id	createName_i;
	id	createDone_i;			// "Create" button
	id	setMatrix_i;			// Texture Set radio-button matrix
	id	textureSetField_i;		// Texture Set field in Texture Editor
	id	newSetButton_i;			// Create New Set button
	id	patchSearchField_i;		// Search for patch string

	id	patchImages;			// Patch Palette images
	
	int	selectedPatch;			// in the Patch Palette
	id	selectedTexturePatches;	// in the Texture Editor View
	id	copyList;				// list of copied patches
	int	currentTexture;			// being edited
	int	oldx,oldy;				// last texture x,y
}

typedef struct
{
	int	sel;
} store_t;

// a patch holds one or more collumns
// Some patches will be in native color, while be used with a color remap table
typedef struct
{
	short	width;				// bounding box size
	short	height;
	short	leftoffset;			// pixels to the left of origin
	short	bottomoffset;		// pixels below the origin
	int		collumnofs[256];	// only [width] used, the [0] is
								// &collumnofs[width]
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
	NXSize	size;
	char		name[9];
	id		image;
	id		image_x2;
	int		WADindex;
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

- (int)numSets;
- findPatch:sender;
- searchForPatch:sender;
- changedWidthOrHeight:sender;
- setOldVars:(int)x :(int)y;
- doLockToggle;
- togglePatchLock:sender;
- deleteCurrentPatch:sender;
- sortUp:sender;
- sortDown:sender;

- updateTexPatchInfo;
- getSTP;
- changeSelectedTexturePatch:(int)which	to:(int)val;
- addSelectedTexturePatch:(int)val;
- (BOOL) selTextureEditPatchExists:(int)val;
- removeSelTextureEditPatch:(int)val;
- (int)getCurrentEditPatch;
- (int)findHighestNumberedPatch;
- changePatchX:sender;
- changePatchY:sender;

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
- createTextureName:sender;
- createTextureAbort:sender;
- createNewSet:sender;

- newSelection:(int)which;
- setSelectedPatch:(int)which;
- selectPatchAndScroll:(int)patch;
- (int)getOutlineFlag;
- dumpAllPatches;
- initPatches;
- createPatchX2:(apatch_t *)p;
- menuTarget:sender;
- computePatchDocView: (NXRect *)theframe;
- setWarning:(BOOL)state;
- saveFrame;

- (int)getNumPatches;
- (int)findPatchIndex:(char *)name;
- (char *)getPatchName:(int)which;

- locatePatchInTextures:sender;

@end

id	patchToImage(patch_t *patchData, unsigned short *shortpal,
	NXSize *size,char *name);
char *strupr(char *string);
char *strlwr(char *string);
