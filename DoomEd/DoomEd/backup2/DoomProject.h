#import <appkit/appkit.h>

//============================================================================

#define MAXPATCHES	100
// mappatch_t orients a patch inside a maptexturedef_t
typedef struct
{
	int		originx;		// block origin (allways UL), which has allready accounted
	int		originy;		// for the patch's internal origin
	char		patchname[9];
	int		stepdir;		// allow flipping of the texture DEBUG: make this a char?
	int		colormap;
} worldpatch_t;

typedef struct
{
	char		name[9];
	BOOL	dirty;		// true if changed since last texture file load
	
	int	width;
	int	height;
	int	patchcount;
	worldpatch_t	patches[MAXPATCHES]; // [patchcount] drawn back to front into the
} worldtexture_t;

// a sectordef_t describes the features of a sector without listing the lines
typedef struct
{
	int	floorheight, ceilingheight;
	char 	floorflat[9], ceilingflat[9];
	int	lightlevel;
	int	special;	
} sectordef_t;

typedef struct
{
	char		name[9];
	BOOL	dirty;		// true if changed since last ends file load
	sectordef_t	s;
} worldends_t;


//============================================================================

extern	id	doomproject_i;
extern	id	wadfile_i;

extern	int	numtextures, numends;
extern	worldtexture_t		*textures;
extern	worldends_t		*ends;

//============================================================================

@interface DoomProject : Object
{
	BOOL	loaded;
	char		projectdirectory[1024];
	char		wadfile[1024];
	int		nummaps;
	char		mapnames[100][9];
	
	int		endssize, texturessize;
	
	id		window_i;
	id		projectpath_i;
	id		wadpath_i;
	id		maps_i;
	
	BOOL	projectdirty, texturesdirty, endsdirty;
}


- init;
- (BOOL)loaded;
- (char *)wadfile;
- (char const *)directory;

- menuTarget: sender;
- openProject: sender;
- newProject: sender;
- saveProject: sender;
- reloadProject: sender;
- openMap: sender;
- newMap: sender;
- removeMap: sender;

- loadProject: (char const *)path;
- updateTextures;
- updateEnds;

- updatePanel;

- (int)textureNamed: (char const *)name;
- (int)endsNamed: (char const *)name;

- (BOOL)readTexture: (worldtexture_t *)tex from: (FILE *)file;
- writeTexture: (worldtexture_t *)tex to: (FILE *)file;

- (int)newTexture: (worldtexture_t *)tex;
- changeTexture: (int)num to: (worldtexture_t *)tex;

- (int)newEnds: (worldends_t *)en;
- changeEnds: (int)num to: (worldends_t *)en;

- saveDoomLumps;

@end

void IO_Error (char *error, ...);
