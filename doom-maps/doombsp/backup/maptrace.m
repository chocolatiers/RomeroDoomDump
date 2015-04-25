#import <libc.h>
#import <appkit/Window.h>
#import <appkit/Application.h>
#import <appkit/View.h>
#import <dpsclient/wraps.h>
#import "cmdlib.h"
#import "maptrace.h"

BOOL	draw = NO;

segment_t	segs[MAXTOTALSEGS], *newseg_p;
bspnode_t	nodes[MAXNODES], *node_p;

#define SHORT(x) NXSwapLittleShortToHost(x)

/*
=====================
=
= DrawSeg
=
=====================
*/

void DrawSeg (segment_t *seg)
{
	float	coordinate, min, max;
	
	if (!draw)
		return;
		
	coordinate = (float)seg->coordinate/256;
	min = (float)seg->min/256;
	max = (float)seg->max/256;
	
	if (seg->orientation)
	{
		PSmoveto (coordinate*BLOCKSCALE,(64-min)*BLOCKSCALE);
		PSlineto (coordinate*BLOCKSCALE,(64-max)*BLOCKSCALE);
	}
	else
	{
		PSmoveto (min*BLOCKSCALE,(64-coordinate)*BLOCKSCALE);
		PSlineto (max*BLOCKSCALE,(64-coordinate)*BLOCKSCALE);
	}
	PSstroke ();
}


/*
================
=
= DrawTile
=
================
*/

void DrawTile (int x, int y, int color)
{
	float		red,green,blue;
	NXRect	aRect;
	
	if (!draw)
		return;
		
	red = (color&3)*0.1;
	green = ((color&12)>>2)*0.1;
	blue = ((color&48)>>4)*0.1;
	
	PSsetrgbcolor (red,green,blue);
	NXSetRect (&aRect,x*BLOCKSCALE,(63-y)*BLOCKSCALE
	,BLOCKSCALE,BLOCKSCALE); 
	NXRectFill (&aRect);
}


/*
==============
=
= OpenWindow
=
==============
*/

void OpenWindow (void)
{
	NXRect	aRect;
	
	if (!draw)
		return;
		
	NXSetRect (&aRect,16,72,64*BLOCKSCALE,64*BLOCKSCALE);

	tilewindow_i = 
	[[Window alloc]
		initContent:	&aRect
		style:		NX_TITLEDSTYLE
		backing:		NX_RETAINED
		buttonMask:	0
		defer:		NO
	];

	[tilewindow_i display];
	[tilewindow_i orderFront:nil];
	tileview_i = [tilewindow_i contentView];
}


/*
================
=
= DrawMap
=
================
*/

void DrawMap (void)
{
	int		x,y;
	
	if (!draw)
		return;
	[tileview_i lockFocus];

	for (y=0;y<64;y++)
		for (x=0;x<64;x++)
			DrawTile (x,y,back[y][x]);

	[tileview_i unlockFocus];
	NXPing ();
}


/*
===============================================================================

							AREA FLOOD FILLING

===============================================================================
*/

// areamap starts out with all solid tile being >= 0x80, and all open tiles having the soundarea (0-62)
// door tiles should have area 63 
// the open areas are set to 0x7f as map.tilemap is filled in with the enclosed area numbers

byte	areamap[64][64];

/*
=================
=
= FloodFill
=
=================
*/

void FloodFill (int x, int y, int fill)
{
	int	old;
	
	old = areamap[y][x];
	areamap[y][x] = 0x7f;		// this spot has been filled
	map.tilemap[y][x] = fill;
	back[y][x] = 0;
	
	if (areamap[y][x-1] == old)
		FloodFill (x-1,y,fill);
	if (areamap[y][x+1] == old)
		FloodFill (x+1,y,fill);
	if (areamap[y-1][x] == old)
		FloodFill (x,y-1,fill);
	if (areamap[y+1][x] == old)
		FloodFill (x,y+1,fill);
}


/*
=================
=
= FloodMap
=
=================
*/

void FloodMap (void)
{
	int	x,y;
	int	i, tile;
	int	areanum;
	
//
// create the areamap by setting all solid tiles to 0x80+tile and all open tiles to areanum
//
	for (y=0 ; y<64 ; y++)
		for (x=0 ; x<64 ; x++)
		{
			tile = back[y][x];
			if (tile < AREATILES)
			{
				areamap[y][x] = 0x80 + tile;
				map.tilemap[y][x] = 0x80 + tile;
			}
			else
			{
				areamap[y][x] = tile - AREATILES;
				map.tilemap[y][x] = 0;
			}
		}
		
//
// find every contained space in the map
//
	areanum = 0;

	for (y=0 ; y<64 ; y++)
		for (x=0 ; x<64 ; x++)
		{
			tile = areamap[y][x];
			if (tile == 63)
				map.tilemap[y][x] = 63;	// door area
			else if (tile < 63)
			{						// unflooded open area
				map.areasoundnum[ areanum ] = tile;
				FloodFill (x,y, areanum);
				areanum++;
//				DrawMap ();
//				getchar();
			}
		}
}




/*
===============================================================================

							BSP DIVISION

===============================================================================
*/

/*
=====================
=
= CountSegSplits
=
= front side is towards more positive coordinates
=====================
*/

void CountSegSplits (
	segment_t 	*list, 
	orientation_t 	splitdir, 
	int 			splitpoint, 
	int 			*frontcnt, 
	int 			*backcnt)
{
	segment_t	*seg_p;
	int			backcount, frontcount;
	
	frontcount = backcount = 0;
	
	for (seg_p = list ; seg_p ; seg_p = seg_p->next)
	{
		if (seg_p->orientation == splitdir)
		{
			if (seg_p->coordinate < splitpoint)
				backcount++;
			else if (seg_p->coordinate > splitpoint)
				frontcount++;
			else
			{
				if (seg_p->dir == di_north || seg_p->dir == di_east)
					frontcount++;
				else
					backcount++;
			}
		}
		else
		{
			if (seg_p->max <= splitpoint)
				backcount++;
			else if (seg_p->min >= splitpoint)
				frontcount++;
			else
			{
				backcount++;
				frontcount++;		// split the segment
			}
		}
	}
	
	*frontcnt = frontcount;
	*backcnt = backcount;
}


/*
=====================
=
= SplitSegs
=
= front side is towards more positive coordinates
=====================
*/

void SplitSegs (
	segment_t 	*list, 
	orientation_t 	splitdir, 
	int 			splitpoint, 
	segment_t 	**frontlist, 
	segment_t 	**backlist)
{
	segment_t	*next, *seg_p, *fronthead, *backhead;
	
	fronthead = backhead = 0;
	
	for (seg_p = list ; seg_p ; seg_p = next)
	{
		next = seg_p->next;
		
		if (seg_p->orientation == splitdir)
		{
			if (seg_p->coordinate < splitpoint)
			{
				seg_p->next = backhead;
				backhead = seg_p;
			}
			else if (seg_p->coordinate > splitpoint)
			{
				seg_p->next = fronthead;
				fronthead = seg_p;
			}
			else
			{
				if (seg_p->dir == di_north || seg_p->dir == di_east)
				{
					seg_p->next = fronthead;
					fronthead = seg_p;
				}
				else
				{
					seg_p->next = backhead;
					backhead = seg_p;
				}
			}
		}
		else
		{
			if (seg_p->max <= splitpoint)
			{
				seg_p->next = backhead;
				backhead = seg_p;
			}
			else if (seg_p->min >= splitpoint)
			{
				seg_p->next = fronthead;
				fronthead = seg_p;
			}
			else
			{
			// split the seg
				*newseg_p = *seg_p;
				seg_p->max = splitpoint;
				newseg_p->min = splitpoint;
				
				seg_p->next = backhead;
				backhead = seg_p;
				newseg_p->next = fronthead;
				fronthead = newseg_p;
				newseg_p++;
			}
		}
	}
	
	*frontlist = fronthead;
	*backlist = backhead;
}


/*
================
=
= BSPList
=
= Returns the node for the given list
================
*/

int	depth = 0;

int BSPList (segment_t *list, float xl, float yl, float xh, float yh)
{
	bspnode_t	*thisnode_p;
	segment_t	*check, *bestcheck, *frontlist, *backlist;
	int			node;
	int			totalsegs, bestnew, bestsplit, newsegs, split, front, back;
	float			floatsplit;
//
// draw rectangle around segs
//
	if (draw)
	{
#if 0
	{
	NXRect rec;	
	PSsetrgbcolor (0,0,0);
	NXSetRect (&rec, 0,0, 64*BLOCKSCALE,64*BLOCKSCALE);
	NXRectFill (&rec);
	}
#endif
		PSsetrgbcolor (1,1,1);
		
		PSsetalpha (0.1);
		PScompositerect (xl*BLOCKSCALE,(64-yh)*BLOCKSCALE, 
			(xh-xl)*BLOCKSCALE, (yh-yl)*BLOCKSCALE, NX_SOVER);
		PSsetalpha (1);
	
		PSmoveto (xl*BLOCKSCALE,(64-yl)*BLOCKSCALE);
		PSlineto (xh*BLOCKSCALE,(64-yl)*BLOCKSCALE);
		PSlineto (xh*BLOCKSCALE,(64-yh)*BLOCKSCALE);
		PSlineto (xl*BLOCKSCALE,(64-yh)*BLOCKSCALE);
		PSlineto (xl*BLOCKSCALE,(64-yl)*BLOCKSCALE);
		PSstroke ();
	
		if (depth)
			PSsetrgbcolor (1,0,0);
		else
			PSsetrgbcolor (0,1,0);
		depth ^= 1;
		
		for (check = list ; check ; check=check->next)
			DrawSeg (check);
		
		[tilewindow_i flushWindow];
		NXPing ();
	}
//
// count segs in list
//
	totalsegs=0;
	for (check = list ; check ; check=check->next)
		totalsegs++;
	
//
// find the best split point
//
	bestsplit = 0;
	bestnew = 0xffff;
	
	for (check = list ; check ; check=check->next)
	{
		CountSegSplits (list, check->orientation, check->coordinate, &front, &back);
		if (!front || !back)
			continue;		// must seperate at least one seg
		newsegs = front+back - totalsegs;
	
		split = front > back ? back : front;
		if (newsegs <= bestnew && split > bestsplit)
		{
			bestnew = newsegs;
			bestsplit = split;
			bestcheck = check;
		}
	}
//
// split it
//
	thisnode_p = node_p;
	node = node_p-nodes;
	node_p++;
	
	if (bestnew == 0xffff)
	{	// remaining segs are convex, no need to split
		thisnode_p->segs = list;
		return node;
	}
#if 0
CountSegSplits (list, bestcheck->orientation, bestcheck->coordinate, &front, &back);
printf ("front: %i  back: %i  new: %i  split: %i\n",front, back, bestnew, bestsplit);
#endif
	thisnode_p->segs = NULL;
	thisnode_p->orientation = bestcheck->orientation;
	thisnode_p->coordinate = bestcheck->coordinate;
	if (thisnode_p->orientation == or_vertical)
	{
		thisnode_p->min = yl*2;
		thisnode_p->max = yh*2;
	}
	else
	{
		thisnode_p->min = xl*2;
		thisnode_p->max = xh*2;
	}
	
	SplitSegs (list, bestcheck->orientation, bestcheck->coordinate, &frontlist, &backlist);
	floatsplit = (float)bestcheck->coordinate/256;
	if (bestcheck->orientation == or_horizontal)
	{
		thisnode_p->frontnode = BSPList (frontlist, xl, floatsplit, xh, yh);
		thisnode_p->backnode = BSPList (backlist, xl, yl, xh, floatsplit);
	}
	else
	{
		thisnode_p->frontnode = BSPList (frontlist, floatsplit, yl, xh, yh);
		thisnode_p->backnode = BSPList (backlist, xl, yl, floatsplit,yh);
	}
	return node;
}

/*
================
=
= BSPMap
=
================
*/

void BSPMap (void)
{
	segment_t	*check;
	int	startnode;
	
//
// link the segs into one list
//
	for (check = segs ; check<newseg_p-1 ; check++)
		check->next = check+1;
	check->next = 0;

	node_p = nodes;
	
	PSsetlinewidth (2);

	startnode = BSPList (segs, 0,0, 64, 64);
}

//==============================================================================
typedef struct
{
	int	x,y,area,tile, psegnum;
} pwall_t;

pwall_t	pwalls[128];
int		numpwalls;

/*
================
=
= AddSeg
=
================
*/

void AddSeg (dir_t dir, float coordinate, float min, float max, int texture)
{
	newseg_p->dir = dir;
	newseg_p->orientation = 1^(dir&1);
	newseg_p->coordinate = coordinate*256;
	newseg_p->min = min*256;
	newseg_p->max = max*256;
	newseg_p->texture = texture;
	DrawSeg (newseg_p);
	newseg_p++;
}

/*
===============
=
= RemovePWalls
=
===============
*/

void RemovePWalls (void)
{
	int		x,y,area;

	numpwalls = 0;
	
	for (y=0;y<64;y++)
		for (x=0;x<64;x++)
		{
			if (front[y][x] != PUSHWALL)
				continue;
				
			if (back[y][x-1] >= AREATILES)
				area = back[y][x-1];
			else if (back[y][x+1] >= AREATILES)
				area = back[y][x+1];
			else if (back[y-1][x] >= AREATILES)
				area = back[y-1][x];
			else if (back[y+1][x] >= AREATILES)
				area = back[y+1][x];
			else
				Error ("Enclosed pushwall at %i,%i",x,y);
				
			pwalls[numpwalls].x = x;
			pwalls[numpwalls].y = y;
			pwalls[numpwalls].area = area;
			pwalls[numpwalls].tile = back[y][x];
			numpwalls++;
			back[y][x] = area;
		}
}

/*
===============
=
= FindDoors
=
===============
*/

void FindDoors (void)
{
	int		x,y, tile, area;

//
// extract doors
//
	numdoors = 0;
	memset (doornum,0,sizeof(doornum));
	for (y=0;y<64;y++)
		for (x=0;x<64;x++)
		{
			tile = back[y][x];

			if (tile < DOORTILE || tile > LASTDOORTILE)
				continue;
			front[y][x] = tile;
			doornum[y][x] = numdoors;
			numdoors++;
		}	
	
}

/*
===============
=
= RemoveDoors
=
===============
*/

#define HDOORAREA	120
#define VDOORAREA	121

void RemoveDoors (void)
{
	int		x,y, tile, area;

//
// extract doors
//
	numdoors = 0;
	memset (doornum,0,sizeof(doornum));
	for (y=0;y<64;y++)
		for (x=0;x<64;x++)
		{
			tile = back[y][x];

			if (tile < DOORTILE || tile > LASTDOORTILE)
				continue;
			if (tile & 1)
				front[y][x] = HDOORAREA;	// horizontal door
			else
				front[y][x] = VDOORAREA;	// vertical door
#if 0
			if (back[y][x-1] >= AREATILES)
				area = back[y][x-1];
			else if (back[y][x+1] >= AREATILES)
				area = back[y][x+1];
			else if (back[y-1][x] >= AREATILES)
				area = back[y-1][x];
			else if (back[y+1][x] >= AREATILES)
				area = back[y+1][x];
			else
				Error ("Enclosed door at %i,%i",x,y);
				
			back[y][x] = area;
#endif
		}	
}


/*
================
=
= CreateSegments
=
================
*/

void CreateSegments (void)
{
	int		x,y;
	int		state;
	int		tile, backtile;
	boolean	 topsolid, bottomsolid;
	int		min;

//
// create segments
//
// Doors are entered as wall 0x80 + 0x40*side + doornum
//
	newseg_p = segs;
	
	if (draw)
	{
		[tileview_i lockFocus];
		PSsetrgbcolor (0,0,0);
		PSsetlinewidth (2);
    	}
		
//
// do horizontal segs
//
	for (y=1;y<64;y++)
	{
		state = 3;
		for (x=1;x<64;x++)
		{
			tile = back[y][x];
			backtile = back[y-1][x];
			
			if (backtile >= DOORTILE && backtile <= LASTDOORTILE)
				topsolid = 8;
			else
				topsolid = backtile < AREATILES;

			if (tile >= DOORTILE && tile <= LASTDOORTILE)
				bottomsolid = 8;
			else
				bottomsolid = tile < AREATILES;
	
			if  ( (topsolid<<1) + bottomsolid == state)
				continue;		// same as last tile

			if (state == 1)
				AddSeg (di_west, y, min, x, y);  // end of bottom solid wall
			if (state == 2)
				AddSeg (di_east, y, min, x, y-1);  // end of top solid wall
				
			if (bottomsolid == 8)
			{	// handle door tiles explicitly
				if (topsolid)
				{	// vertical door
					AddSeg (di_east, y, x, x+1, 128); 
					AddSeg (di_west, y+1, x, x+1, 128); 
				}
				else
				{	// horizontal door
					AddSeg (di_east, y+0.5, x, x+1, 129+doornum[y][x]); 
					AddSeg (di_west, y+0.5, x, x+1, 129+doornum[y][x]); 
				}			
			}
			
			state = (topsolid<<1) + bottomsolid;
			min = x;
		}
	}
		
//
// do vertical segs
//
	for (x=1;x<64;x++)
	{
		state = 3;
		for (y=1;y<64;y++)
		{
			tile = back[y][x];
			backtile = back[y][x-1];
			
			if (backtile >= DOORTILE && backtile <= LASTDOORTILE)
				topsolid = 8;
			else
				topsolid = backtile < AREATILES;

			if (tile >= DOORTILE && tile <= LASTDOORTILE)
				bottomsolid = 8;
			else
				bottomsolid = tile < AREATILES;

			if  ( (topsolid<<1) + bottomsolid == state)
				continue;		// same as last tile

			if (state == 1)
				AddSeg (di_south, x, min, y, 64+x);  // end of bottom solid wall
			if (state == 2)
				AddSeg (di_north, x, min, y, 64+x-1);  // end of top solid wall
	
			if (bottomsolid == 8)
			{	// handle door tiles explicitly
				if (topsolid)
				{	// horizontal door
					AddSeg (di_north, x, y, y+1, 128); 
					AddSeg (di_south, x+1, y, y+1, 128); 
				}
				else
				{	// vetical door
					AddSeg (di_south, x+0.5, y, y+1, 129+ doornum[y][x]); 
					AddSeg (di_north, x+0.5, y, y+1, 129+doornum[y][x]); 
				}			
			}
			
			state = (topsolid<<1) + bottomsolid;
			min = y;
		}
	}
	
	if (draw)
	{	
		NXPing ();
		[tilewindow_i flushWindow];
	}
}

/*
================
=
= SetupMap
=
================
*/

void SetupMap (int num)
{
	int		x,y;
	int		solid;
  	int		area;
	
	LoadMap (num);	// loads into back / front
	for (x=0 ; x<4096 ; x++)
	{
		back[0][x] = mapplanes[0][x];
		front[0][x] = mapplanes[1][x];
	}
	
	DrawMap ();
	memset (&map,0,sizeof(map));
	RemovePWalls ();
	FindDoors ();
	CreateSegments ();
//	RemoveDoors ();	
	FloodMap ();
}

/*
===============================================================================

								SAVING


===============================================================================
*/

savenode_t	*savenodes, *savenode_p;

/*
===============
=
= OutputSegs
=
= Adds the segments to the save list and returns the number converted
===============
*/

void OutputSegs (segment_t *seg)
{
	int			x,y;
	saveseg_t	*saveseg_p;
		
	for ( ; seg ; seg = seg->next)
	{
		saveseg_p = (saveseg_t *)savenode_p;
		savenode_p++;

		saveseg_p->dir = seg->dir | DIR_SEGFLAG;
		saveseg_p->plane = seg->coordinate>>7;  // cut to half tiles
		saveseg_p->min = seg->min>>7;		// cut down to half tiles
		saveseg_p->max = seg->max>>7;	// cut down to half tiles
		saveseg_p->texture = seg->texture;

	// find the area the seg bounds
		switch (seg->dir)
		{	// get coorinates of an open tile bordering the seg
		case di_north:
			x = seg->coordinate+32;
			y = (seg->min + seg->max)>>1;
			break;
		case di_south:
			x = seg->coordinate-32;
			y = (seg->min + seg->max)>>1;
			break;
		case di_east:
			y = seg->coordinate+32;
			x = (seg->min + seg->max)>>1;
			break;
		case di_west:
			y = seg->coordinate-32;
			x = (seg->min + seg->max)>>1;
			break;
		}
		saveseg_p->area = map.tilemap[y>>8][x>>8];
		if (saveseg_p->area >= 63)
		{
			if (saveseg_p->area >= 0x80+DOORTILE 
			&& saveseg_p->area <= 0x80+LASTDOORTILE)
			{
				if (saveseg_p->area & 1)
				{	// horizontal door
					if (y&255 < 128)
						y -= 256;
					else
						y+= 256;
				}
				else
				{	// vertical door
					if (x&255 < 128)
						x -= 256;
					else
						x+= 256;
				}
			}
			
			saveseg_p->area = map.tilemap[y>>8][x>>8];
			if (saveseg_p->area >= 63)
				Error ("OutputSegs: bad segment area");
		}
	}
	saveseg_p->dir |= DIR_LASTSEGFLAG;
}


/*
====================
=
= OutputNode
=
====================
*/

void OutputNode (int nodenum)
{
	bspnode_t *node;
	savenode_t *snode;
	
	node = &nodes[nodenum];
	
	if (node->segs)
	{
		OutputSegs (node->segs);
		return;
	}

	snode = savenode_p++;
	snode->dir = node->orientation;
	snode->plane = node->coordinate>>7;
	snode->children[0] = savenode_p - savenodes;  // OPTIMIZE: this is invariant
	OutputNode (node->frontnode);
	snode->children[1] = savenode_p - savenodes;
	OutputNode (node->backnode);
}


/*
================
=
= SaveMap
=
================
*/

void SaveMap (int area)
{
	char		name[1024];
	int		 handle,numactors,numstatics;
	byte		*dat;
	short	*table;
	int		i, j, len,x, y, tile;
	int		numsavenodes;
	
	numactors = 0;
	numstatics = 0;
	printf ("saving map...\n");
	dat = map.data;
//
// spawn list
//
	map.numspawn = 0;
	map.spawnlistofs = SHORT(dat-(byte *)&map);
	for (y=0 ; y<64 ; y++)
		for (x=0 ; x<64 ; x++)
		{
			tile = front[y][x];
			if (tile)
			{
				*dat++ = x;
				*dat++ = y;
				*dat++ = tile;
				if (tile == PUSHWALL)
				{	// pushwalls get an extra byte for the tile number
					for (i=0 ; i<numpwalls ; i++)
						if (pwalls[i].x == x && pwalls[i].y == y)
							break;
					*dat++ = pwalls[i].tile;
				}
				map.numspawn++;
				if (tile >=108)
					numactors++;
				else if (tile>=23 && tile<=54)
					numstatics++;
			}
		}
printf ("spawn: %i (%i actors, %i statics)\n", map.numspawn, numactors, numstatics);
	map.numspawn = SHORT(map.numspawn);
	

//
// compact and save the segs
//
	map.nodelistofs = SHORT(dat-(byte *)&map);
	savenode_p = savenodes = (savenode_t *)dat;
	OutputNode (0);
	numsavenodes = savenode_p - savenodes;
	map.numnodes = SHORT(numsavenodes);
	printf ("nodes: %i \n",numsavenodes);
	
//
// write it out
//
	len = (byte *)savenode_p-(byte *)&map;
//	sprintf (name,"/Net/NetWare/LOTHAR/SYS/x/wolfsnes/newmaps/map%i.bin", area);
	sprintf (name,"/aardwolf/Users/johnc/experiments/BSPTrace/maps/map%i.bin", area);
	handle = SafeOpenWrite ( name );
	SafeWrite (handle,&map, len);
	close (handle);
	printf ("map size: %i\n",len);
}


/*
================
=
= main
=
================
*/

void main (int argc, char **argv)
{
	int	i, start, stop;
	
	setbuf (stdout,0);
	setbuf (stderr,0);

	if (argc == 2)
	{
		start = stop = atoi(argv[1]);
	}
	else if (argc == 3)
	{
		start = atoi(argv[1]);
		stop = atoi(argv[2]);
	}
	else if (argc == 4)
	{
		draw = YES;	
		start = atoi(argv[1]);
		stop = atoi(argv[2]);
	}
	else
	{
		start = 0;
		stop = 0;
	}
draw = YES;
	NXApp = [Application new];
    
	LoadTedHeader ("wls");

	OpenWindow ();
	
	for (i=start ; i<=stop ; i++)
	{
		memset (&map, 0, sizeof(map));
		SetupMap (i);
printf ("\nmap: %i\n",i);
		BSPMap ();
		SaveMap (i);
		free (mapplanes[0]);
		free (mapplanes[1]);
		free (mapplanes[2]);
//		getc (stdin);
	}

	exit (0);
}

