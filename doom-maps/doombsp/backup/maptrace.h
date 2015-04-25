#define	BLOCKSCALE	8.0
#define	AREATILES		108
#define	DOORTILE		90
#define	LASTDOORTILE	97
#define	PUSHWALL		98

#define	NUMAREAS		32

/*
===============================================================================

The saved data structures are held in a single list, with segs being differentiated from nodes by the
presence of DIR_SEGFLAG in the dir field

===============================================================================
*/

typedef struct
{
	byte		plane;
	byte		dir;
	ushort	children[2];
} savenode_t;

typedef struct
{
	byte		plane;			// in half tiles
	byte		dir;
	byte		min,max;			// in half tiles
	byte		texture;
	byte		area;
} saveseg_t;

#define	DIR_SEGFLAG		0x80
#define	DIR_LASTSEGFLAG	0x40

typedef struct
{
	byte		tilemap[64][64];
	byte		areasoundnum[64];
	short	numspawn;
	short	spawnlistofs;
	short	numnodes;
	short	nodelistofs;
	byte		data[0x8000];		// nodes, and spawn list
} loadmap_t;

//==============================================================================

byte	back[64][64];
byte	front[64][64];

extern	USHORT				*mapplanes[3];

//==============================================================================

loadmap_t	map;

int	numdoors;
byte	doornum[64][64];
byte	areamap[64][64];

byte	walls[2][64][64];

id	tilewindow_i,tileview_i;
id	NXApp;

int	areanum;

int		tilex, tiley;

typedef enum {or_horizontal, or_vertical} orientation_t;

// the direction is from point 1 (view left) to point 2 (view right)
typedef enum {di_north, di_east, di_south, di_west} dir_t;

typedef struct segment_s
{
	struct segment_s	*next;
	orientation_t	orientation;
	dir_t			dir;
	int			coordinate;
	int			min, max;
	int			texture;
} segment_t;

typedef struct
{
	segment_t	*segs;		// if non NULL, its a terminal node
	
	orientation_t	orientation;	// only valid if segs is NULL
	int			coordinate;
	int			min, max;
	int			frontnode, backnode;
} bspnode_t;

#define	MAXTOTALSEGS	8192
#define	MAXNODES		2048

