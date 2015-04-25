#import <appkit/appkit.h>
#import "DoomProject.h"

#define	WORLDNAME	"EditWorld"

typedef struct
{
	int	selected;		// context that owns the point, 0 if unselected, or -1 if deleted
	int	refcount;		// when 0, remove it 

	NXPoint	pt;
} worldpoint_t;

typedef struct
{
	int		flags;	
	int		firstcollumn;
	char		toptexture[9];
	char		bottomtexture[9];
	char		midtexture[9];
	sectordef_t	ends;				// on the viewer's side
	int		sector;					// only used when saving doom map
} worldside_t;

typedef struct
{
	int	selected;			// 0 if unselected, -1 if deleted, 1 if selected, 2 if back side selected
	
	int	p1, p2;
	int	special, tag;
	int	flags;
	
	worldside_t	side[2];

	NXPoint	mid;
	NXPoint	norm;
} worldline_t;

#define	ML_BLOCKMOVE			1
#define	ML_TWOSIDED			4	// backside will not be present at all if not two sided

typedef struct
{
	int	selected;		// 0 if unselected, -1 if deleted, 1 if selected

	NXPoint	origin;
	int	angle;
	int	type;
	int	options;
	int	area;
} worldthing_t;

typedef struct
{
	sectordef_t	s;
	id	lines;			// storage object of line numbers
} worldsector_t;

typedef struct
{
	worldline_t	l;
	NXPoint		p1,p2;
} copyline_t;

//===========================================================================
// GLOBAL variables

extern	id			editworld_i;

extern	int			numpoints, numlines, numthings;

extern	worldpoint_t	*points;
extern	worldline_t	*lines;
extern	worldthing_t	*things;

//===========================================================================

@interface EditWorld : Object
{
	BOOL	loaded;
	
	int		pointssize, linessize, thingssize, texturessize;	// array size >= numvalid
	BOOL	dirty, dirtypoints;		// set whenever the map is changed FIXME
	NXRect	bounds;
	BOOL	boundsdirty;
	char		pathname[1024];
	NXRect	dirtyrect;	
	id		windowlist_i;			// all windows that display this world
	
	id		copyThings_i;			// cut/copy/paste info
	id		copyLines_i;
	NXPoint	copyCoord;
	int		copyLoaded;
	id		saveSound;				// Sound instance
}

- appWillTerminate: sender;
- loadWorldFile: (char const *)path;
- saveDoomEdMapBSP:sender;

- (BOOL)loaded;
- (BOOL)dirty;
- (BOOL)dirtyPoints;

- closeWorld;

//
// menu targets
//
- newWindow:sender;
- saveWorld:sender;
- print:sender;

//
// selection operations
//

- cut: sender;
- copy: sender;
- paste: sender;
- delete: sender;
- flipSelectedLines: sender;
- fusePoints: sender;
- seperatePoints: sender;

//
// dealing with map windows
//
- windowWillClose: sender;
- updateWindows;
- addToDirtyRect: (int)p1 : (int)p2;
- updateLineNormal:(int) num;
- redrawWindows;
- getMainWindow;	// returns window id

//
// get info
//
- getBounds: (NXRect *)theRect;

//
// change info
//
- selectPoint: (int)num;
- deselectPoint: (int)num;
- selectLine: (int)num;
- deselectLine: (int)num;
- selectThing: (int)num;
- deselectThing: (int)num;
- deselectAllPoints;
- deselectAllLines;
- deselectAllThings;
- deselectAll;


- (int)allocatePoint: (NXPoint *)pt;
- (int)newPoint: (NXPoint *)pt;
- (int)newLine: (worldline_t *)line from: (NXPoint *)p1 to:(NXPoint *)p2;
- (int)newThing: (worldthing_t *)thing;

- changePoint: (int)p to: (worldpoint_t *)data;
- changeLine: (int)p to: (worldline_t *)data;
- changeThing: (int)p to: (worldthing_t *)data;


//
// Cut/copy/paste stuff
//
- storeCopies;
- copyDeselect;
- (NXPoint)findCopyCenter;
- (int)findMin:(int)num0	:(int)num1;
- (int)findMax:(int)num0	:(int)num1;
@end


//
// EWLoadSave catagory
//
@interface EditWorld (EWLoadSave)

- (BOOL)readLine: (NXPoint *)p1 : (NXPoint *)p2 : (worldline_t *)line from: (FILE *)file;
- writeLine: (worldline_t *)line to: (FILE *)file;
- (BOOL)readThing: (worldthing_t *)thing from: (FILE *)file;
- writeThing: (worldthing_t *)thing to: (FILE *)file;

- loadV4File: (FILE *)file;
- saveFile: (FILE *)file;

@end

//
// EWDoomSave catagory
//
@interface EditWorld (EWDoomSave)

- saveDoomMap;

@end

int LineByPoint (NXPoint *pt, int *side);
