#import <appkit/appkit.h>

//============================================================================
#define	DOOMNAME		"DoomEd"
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
	int		WADindex;	// which WAD it's from!  (JR 5/28/93 )
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
	int	special, tag;	
} sectordef_t;

//============================================================================

extern	id	doomproject_i;
extern	id	wadfile_i;
extern	id	log_i;

extern	int	numtextures;
extern	worldtexture_t		*textures;

extern	char	mapwads[1024];		// map WAD path
extern	char	bspprogram[1024];	// bsp program path
extern	char	bsphost[32];		// bsp host machine

//============================================================================

@interface DoomProject : Object
{
	BOOL	loaded;
	char	projectdirectory[1024];
	char	wadfile[1024];		// WADfile path
	int		nummaps;
	char	mapnames[100][9];
	
	int		texturessize;
	
	id		window_i;
	id		projectpath_i;
	id		wadpath_i;
	id		maps_i;
	id		thingPanel_i;
	id		findPanel_i;
	id		mapNameField_i;
	id		BSPprogram_i;
	id		BSPhost_i;
	id		mapwaddir_i;
	
	BOOL	projectdirty;
	BOOL	texturesdirty;
	BOOL	mapdirty;
	
	id		thermoTitle_i;
	id		thermoMsg_i;
	id		thermoView_i;
	id		thermoWindow_i;
	
	id		printPrefWindow_i;
}


- init;
- displayLog:sender;
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
- printMap:sender;
- printAllMaps:sender;

- loadProject: (char const *)path;
- updateTextures;

- updatePanel;

- (int)textureNamed: (char const *)name;

- (BOOL)readTexture: (worldtexture_t *)tex from: (FILE *)file;
- writeTexture: (worldtexture_t *)tex to: (FILE *)file;

- (int)newTexture: (worldtexture_t *)tex;
- changeTexture: (int)num to: (worldtexture_t *)tex;

- saveDoomLumps;
- loadAndSaveAllMaps:sender;
- printStatistics:sender;
- printSingleMapStatistics:sender;
- updateThings;
- updateSectorSpecials;
- updateLineSpecials;
- saveFrame;
- changeWADfile:(char *)string;
- quit;
- setDirtyProject:(BOOL)truth;
- setDirtyMap:(BOOL)truth;
- (BOOL)projectDirty;
- (BOOL)mapDirty;
- checkDirtyProject;

- printPrefs:sender;
- togglePanel:sender;
- toggleMonsters:sender;
- toggleItems:sender;
- toggleWeapons:sender;

// Thermometer functions
- initThermo:(char *)title message:(char *)msg;
- updateThermo:(int)current max:(int)maximum;
- closeThermo;


//	Map Loading Functions
- beginOpenAllMaps;
- (BOOL)openNextMap;

@end

void IO_Error (char *error, ...);
void DE_DrawOutline(NXRect *r);
