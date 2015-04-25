// R_mapdef.h
// included by R_local.h in doom and by WorldServer.m in the WorldServer

// in the map file, all pointers are offsets from the start of file

#ifndef __FRAC__
#define __FRAC__
#define	FRACBITS		16
#define	FRACUNIT		(1<<FRACBITS)
// A fixed_t has 16 bits of unit and 16 bits of fraction
typedef int	fixed_t;
#endif

#ifndef __BYTEBOOL__
#define __BYTEBOOL__
typedef unsigned char byte;
typedef enum {false, true} boolean;
#endif

// A mapvertex_t is a global map point
typedef struct
{
	short	x,y;
} mapvertex_t;

// A mapthing_t is a point and some information from the map editor.  These are only processed
// at map loading time, where they spawn visible thing_ts or other game objects
typedef struct
{
	mapvertex_t	origin;
	short	angle;
	short	type;
	short	options;
	short	sector;		// the sector it should be placed in at the start
} mapthing_t;

// mappatch_t orients a patch inside a maptexturedef_t
typedef struct
{
	short	originx;		// block origin (allways UL), which has allready accounted
	short	originy;		// for the patch's internal origin
	short	patch;
	short	stepdir;		// allow flipping of the texture DEBUG: make this a char?
	short	colormap;
} mappatch_t;

// a maptexturedef_t describes a rectangular texture, which is composed of one or
// more mappatch_t structures that arrange graphic patches
typedef struct
{
	char		name[8];				// JR 4/5/93
	boolean	masked;				// if not masked, the patch's post_ts need to be combined
	short	width;
	short	height;
	void		**collumndirectory;		// [width] pointers to collumn_ts to draw the texture
	short	patchcount;
	mappatch_t	patches[1];		// [patchcount] drawn back to front into the cached texture
} maptexture_t;

// A mapends_t defines what to draw on the floor and ceiling of an open area, as well as the
// light level for all sprites and walls in the open area
typedef struct
{
	short		floorheight, ceilingheight;
	short		floortexture, ceilingtexture;
	short		lightlevel;		// base light level
	short		special;			// to allow things to happen on a given floor section
	short		tag;
	short		linecount;
	short		lines[1];			// [linecount] size
} mapsector_t;


// The entire world is defined by maplines with various attributes.
typedef struct
{
	short	flags;	
	short	sector;					// on the viewer's side
	short	firstcollumn;				// first collumn for all textures
	short	midtexture;				// end wall or masked mid texture, -1 = no texture
	short	toptexture;				// texture to fill gaps between ceiling planes
	short	bottomtexture;				// texture to fill gaps between floor planes
} mapside_t;

// if the line is not two sided, the midtexture must cover the entire space

typedef struct
{
	short		p1, p2;				// point numbers
	short		flags;
	short		length;				// texture collumns
	short		special,tag;			// for segment triggers!
	mapside_t	side[2];
} mapline_t;

// Line flags - can go up to 16 bits!

#define	ML_PLAYERBLOCK		1
#define	ML_MONSTERBLOCK		2
#define	ML_TWOSIDED			4	// backside will not be present if not 2-sided
#define	ML_DONTPEGTOP		8
#define	ML_DONTPEGBOTTOM	16
#define ML_SECRET			32	// don't display in automap: IT'S A SECRET!
#define ML_SOUNDBLOCK		64	// blocks sound, eh?
#define ML_DONTDRAW			128	// don't draw in automap

// if a texture is pegged, the texture will have the end exposed to air held constant at the top
// or bottom of the texture (stairs or pulled down things) and will move with a height change of 
// one of the middle lines (doors, etc)
// Unpegged textures allways have the first row of the texture at the top pixel of the line for both
// top and bottom textures (windows)

