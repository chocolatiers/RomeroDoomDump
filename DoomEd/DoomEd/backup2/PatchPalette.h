
#import <appkit/appkit.h>

extern id	patchPalette_i;

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

@interface PatchPalette:Object
{
	id	window_i;
	id	patchImages;
}

- initPatches;
- (int) currentSelection;
- (apatch_t *) getPatch:(int)which;
- menuTarget:sender;

@end

id	patchToImage(patch_t *patchData,byte const *lbmpalette,NXSize *size);
