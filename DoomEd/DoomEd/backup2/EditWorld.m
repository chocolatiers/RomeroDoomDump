#import "EditWorld.h"
#import "idfunctions.h"
#import "MapWindow.h"
#import "MapView.h"
#import "Coordinator.h"
#import "ThingPanel.h"
#import "LinePanel.h"
#import "TextureEdit.h"
#import "grouping.h"

//=============================================================================

id			editworld_i;
int			numpoints, numlines, numthings;

worldpoint_t	*points;
worldline_t	*lines;
worldthing_t	*things;

//=============================================================================

#define	BASELISTSIZE	128


@implementation EditWorld

- (BOOL)loaded
{
	return loaded;
}

- (BOOL)dirty
{
	return dirty;
}

- (BOOL)dirtyPoints
{
	if (dirtypoints)
	{
		dirtypoints = false;
		return true;
	}
	
	return dirtypoints;
}


/*
======================
=
= init
=
=======================
*/

- init
{
	editworld_i = self;
	
//
// set up local structures
//
	windowlist_i = [[List alloc] init];
	numpoints = numlines = numthings = 0;
	pointssize = linessize = thingssize = texturessize = BASELISTSIZE;

	points = malloc (pointssize*sizeof(worldpoint_t));
	lines = malloc (linessize*sizeof(worldline_t));
	things = malloc (thingssize*sizeof(worldthing_t));

	return self;
}

- appWillTerminate: sender
{
// FIXME: prompt to save map if dirty

	[self free];
	return self;
}


/*
==================
=
= loadWorldFile:
=
==================
*/

- loadWorldFile: (char const *)path
{
	FILE		*stream;
	id		ret;
	int		version;

	strcpy (pathname,path);
	dirtyrect.size.width = dirtyrect.size.height = 0;
	boundsdirty = YES;
	
//
// load the file
//
	numpoints = numlines = numthings = 0;

//
// identify which map version the file is
//		
	stream = fopen (pathname,"r");
	if (!stream)
	{
		NXRunAlertPanel ("Error","Couldn't open %s",NULL,NULL,NULL,pathname);
		return nil;	
	}
	version = -1;
	fscanf (stream, "WorldServer version %d\n", &version);
	if (version == 0)
	{	// empty file -- clear stuf out
		
		ret = self;
	}
	else if (version == 4)
		ret = [self loadV4File: stream];
	else
	{
		fclose (stream);
		NXRunAlertPanel ("Error","Unknown file version for %s",NULL,NULL,NULL,pathname);
		return nil;	
	}

	if (!ret)
	{
		fclose (stream);
		NXRunAlertPanel ("Error","Couldn't parse file %s",NULL,NULL,NULL,pathname);
		return nil;	
	}
	
	fclose (stream);
	dirty = NO;
	dirtypoints = YES;		// a connection matrix will be build for flood filling
//
// create a new window
//
	loaded = YES;
	[self newWindow:self];

	return self;
}


/*
==================
=
= closeWorld
=
= Frees all resources so another world can be loaded
=
==================
*/

- closeWorld
{
	[windowlist_i makeObjectsPerform: @selector(free)];
	[windowlist_i free];
	windowlist_i = [[List alloc] init];
		
	numpoints = numlines = numthings = 0;
	loaded = NO;
	return self;
}


/*
===============================================================================

								MENU TARGETS

===============================================================================
*/

- drawConnections: sender
{
	DrawConnectionLines ();
	return self;
}

/*
=====================
=
= newWindow:
=
=====================
*/

- newWindow:sender
{
	id	win;
	
	if (!loaded)
	{
		NXRunAlertPanel ("Error","No world open",NULL,NULL,NULL);
		return nil;
	}
	
			
	win = [[MapWindow alloc] initFromEditWorld];
	if (!win)
		return NULL;
		
	[windowlist_i addObject: win];
	[win setDelegate: self];
	[win setTitleAsFilename: pathname];	
	[win display];
	[win makeKeyAndOrderFront:self];
		
	return self;
}


/*
=====================
=
= saveWorld:
=
=====================
*/

- saveWorld:sender
{
	FILE			*stream;
	id			pan;
	
	if (!loaded)
	{
		NXRunAlertPanel ("Error","No world open",NULL,NULL,NULL);
		return nil;
	}
	
	pan = NXGetAlertPanel ("One moment","Saving",NULL,NULL,NULL);
	[pan display];
	[pan orderFront: NULL];
	NXPing ();
	
	printf ("Saving project\n");
	[doomproject_i saveProject: self];
	
	printf ("Saving DoomEd map\n");
	BackupFile (pathname); 
	stream = fopen (pathname,"w");
	[self saveFile: stream];
	fclose (stream);
		
	printf ("Saving doom map\n");
	[self saveDoomMap];
	
	dirty = NO;
	
	NXFreeAlertPanel	(pan);

	return self;
}


/*
=====================
=
= print:
=
=====================
*/

- print: sender
{
	[[[NXApp mainWindow] mapView] printPSCode: sender];
	
	return self;
}


/*
===============================================================================

					VISUAL RELATED METHODS
	
===============================================================================
*/

/*
====================
=
= updateLineNormal:
=
= Updates the coordinates of the line normal
=
====================
*/

- updateLineNormal:(int) num
{
	worldline_t	*line;
	NXPoint	*p1, *p2;
	float		dx, dy, length;

	line = &lines[num];
	
// FIXME: make two normals for two sided lines?

	p1 = &points[line->p1].pt;
	p2 = &points[line->p2].pt;
	
	dx = p2->x - p1->x;
	dy = p2->y - p1->y;
	length = sqrt (dx*dx + dy*dy)/LINENORMALLENGTH;
	line->mid.x = p1->x + dx/2;
	line->mid.y = p1->y + dy/2;
	line->norm.x = line->mid.x + dy/length;
	line->norm.y = line->mid.y - dx/length;
	
	return self;
}



/*
================
=
= addPointToDirtyRect:
=
================
*/

- addPointToDirtyRect: (NXPoint *)pt
{
	IDEnclosePoint (&dirtyrect, pt);
	return self;
}



/*
================
=
= addToDirtyRect:
=
= The rect around the two points is added to the dirty rect.
=
= Update things adds directly to the dirty rect
=
================
*/

- addToDirtyRect: (int)p1 : (int)p2
{
	[self addPointToDirtyRect: &points[p1].pt];
	[self addPointToDirtyRect: &points[p2].pt];
	return self;
#if 0
	NXRect	new;
	NXPoint	*pt1, *pt2;
	
	pt1 = &points[p1].pt;
	pt2 = &points[p2].pt;
	
	if (pt1->x < pt2->x)
	{
		new.origin.x = pt1->x;
		new.size.width = pt2->x - pt1->x+1;
	}
	else
	{
		new.origin.x = pt2->x;
		new.size.width = pt1->x - pt2->x+1;
	}
	
	if (pt1->y < pt2->y)
	{
		new.origin.y = pt1->y;
		new.size.height = pt2->y - pt1->y+1;
	}
	else
	{
		new.origin.y = pt2->y;
		new.size.height = pt1->y - pt2->y+1;
	}

	NXUnionRect (&new, &dirtyrect);
#endif
	return self;
}



/*
===============================================================================

							WINDOW STUFF
FIXME: Map window is its own delegate now, this needs to be done with a message
===============================================================================
*/

- windowWillClose: sender
{
	[windowlist_i removeObject: sender];
	return self;
}


- updateWindows
{
	int	count;
	
	if (!dirtyrect.size.width)
		return self;		// nothing to update

	count = [windowlist_i count];
	while (--count > -1)
		[[windowlist_i objectAt: count] reDisplay: &dirtyrect];
		
	dirtyrect.size.width = dirtyrect.size.height = 0;
	[linepanel_i updateLineInspector];
	[thingpanel_i updateThingInspector];
	return self;
}

- redrawWindows
{
	[windowlist_i makeObjectsPerform: @selector(display)];

	dirtyrect.size.width = dirtyrect.size.height = 0;
	[linepanel_i updateLineInspector];
	[thingpanel_i updateThingInspector];
	return self;
}

/*
===============================================================================

						RETURN INFORMATION

===============================================================================
*/

#define BOUNDSBORDER	128

- getBounds: (NXRect *)theRect
{
	int		p;
	float		x,y,right, left, top, bottom;
	
	if (boundsdirty)
	{
		right = top = -MAXFLOAT;
		left = bottom = MAXFLOAT;
		
		for (p=0 ; p<numpoints ; p++)
		{
			x = points[p].pt.x;
			y = points[p].pt.y;
			if (x<left)
				left = x;
			if (x>right)
				right = x;
			if (y<bottom)
				bottom = y;
			if (y>top)
				top = y;
		}

		bounds.origin.x = left - BOUNDSBORDER;
		bounds.origin.y = bottom - BOUNDSBORDER;
		bounds.size.width = right -left + BOUNDSBORDER*2 ;
		bounds.size.height = top -bottom + BOUNDSBORDER*2 ;
		
		boundsdirty = NO;
	}
	
	if (bounds.size.width < 0)
	{
		bounds.origin.x = bounds.origin.y = 0;
		bounds.size.width = bounds.size.height = 0;
	}
	
	*theRect = bounds;
	return self;
}


/*
===============================================================================

						NEW DATA ALLOCATION METHODS

FIXME: make these scan for deleted entries

===============================================================================
*/

// allocate a point even if it is a duplicate
- (int)allocatePoint: (NXPoint *)pt
{
// add a new point
	
	if (numpoints == pointssize)
	{
		pointssize += 128;		// add space to array
		points = realloc (points, pointssize*sizeof(worldpoint_t));
	}
	
// set default values
	points[numpoints].pt = *pt;
	points[numpoints].refcount = 1;
	points[numpoints].selected = 0;
	
	numpoints++;
	dirtypoints = true;		// connection matrix will need to be recalculated
	
	return numpoints-1;	
}


/*
================
=
= newPoint:
=
= If an existing point can be used, it's refcount is incremented
=
=================
*/

- (int)newPoint: (NXPoint *)pt
{
	int	i;
	worldpoint_t	*check;

// round the point to integral values
	pt->x = rint(pt->x);
	pt->y = rint(pt->y);
	
// use an existing point if equal

	check = points;
	for (i=0 ; i<numpoints ; i++,check++)
		if (check->selected != -1 && check->pt.x == pt->x && check->pt.y == pt->y)
		{
			check->refcount++;
			return i;
		}

	return [self allocatePoint: pt];
}


/*
================
=
= newLine:from:to:
=
= returns the slot the line was stuck in
=
================
*/

- (int)newLine:(worldline_t *)data from: (NXPoint *)p1 to:(NXPoint *)p2
{	
	if (numlines == linessize)
	{
		linessize += 128;		// add space to array
		lines = realloc (lines, linessize*sizeof(worldline_t));
	}

	lines[numlines].selected = -1;	// signal change that it is a new addition

	numlines++;

	data->p1 = [self newPoint: p1];
	data->p2 = [self newPoint: p2];
	
	dirtypoints = true;		// connection matrix will need to be recalculated

	[self changeLine: numlines-1 to: data];

	return numlines - 1;
}


/*
===============
=
= newThing
=
= The type and origin should be set so the dirty rects can be set
=
===============
*/

- (int)newThing: (worldthing_t *)thing
{	
	if (numthings == thingssize)
	{
		thingssize += 128;		// add space to array
		things = realloc (things, thingssize*sizeof(worldthing_t));
	}
	
	things[numthings].selected = -1;	// signal change that it is a new addition
	
	numthings++;

	[self changeThing: numthings-1 to: thing];
	
	return numthings-1;
}


//=============================================================================



/*
=================
=
= dropPointRefCount
=
= If a point is not used any more, remove it
=
=================
*/

- dropPointRefCount: (int)p
{
	if (--points[p].refcount)
		return self;
		
//	printf ("removing point %i\n",p);	// DEBUG
	points[p].selected = -1;
	
	return self;
}



/*
===============================================================================

					SELECTION MODIFICATION METHODS
						
===============================================================================
*/

/*
========================
=
= flipSelectedLines:
=
= deletes and recreates the selected lines with an oposite direction
=
========================
*/

- flipSelectedLines: sender
{
	worldline_t	line;
	int			i;
	NXPoint		p1,p2;
	
	if (!loaded)
		return self;
	
// FIXME: mutch easier now
	
	for (i=0 ; i<numlines ; i++)
		if (lines[i].selected == 1)
		{
			line = lines[i];
			p1 = points[line.p1].pt;
			p2 = points[line.p2].pt;
			line.selected = -1;
			[self changeLine: i to: &line];		// delete the old line
			line.selected = 0;
			[self newLine: &line from: &p2 to: &p1];  // add a new one
		}
		
	[self updateWindows];

	return self;
}

/*
========================
=
= fusePoints:
=
= All selected points that are at the same location will be set to the same point
=
========================
*/

- fusePoints: sender
{
	int	i, j, k;
	NXPoint	*p1, *p2;
	worldline_t	*line;
	
	for (i=0 ; i<numpoints ; i++)
	{
		if (points[i].selected != 1)
			continue;
		p1 = &points[i].pt;
		//
		// find any points that are on the same spot as point i		//
		for (j=0 ; j<numpoints ; j++)
		{
			if (points[j].selected == -1 || j == i)
				continue;
			p2 = &points[j].pt;
			if (p1->x != p2->x || p1->y != p2->y)
				continue;
			//
			// find all lines that use point j
			//
			for (k=0 ; k<numlines ; k++)
			{
				line = &lines[k];
				if (line->selected == -1)
					continue;
				if (line->p1 == j)
				{
					line->p1 = i;
					points[i].refcount++;
				}
				else if (line->p2 == j)
				{
					line->p2 = i;
					points[i].refcount++;
				}
			}
			points[j].selected = -1;		// remove the duplicate point
		}
	}
	
	[self updateWindows];

	return self;
}


/*
========================
=
= seperatePoints:
=
= All selected points that have a refcount greater than one will have clones made
=
========================
*/

- seperatePoints: sender
{
	int	i, k;
	worldline_t	*line;
	
	for (i=0 ; i<numpoints ; i++)
	{
		if (points[i].selected != 1)
			continue;
		if (points[i].refcount < 2)
			continue;
		for (k=0 ; k<numlines ; k++)
		{
			line = &lines[k];
			if (line->selected == -1)
				continue;
			if (line->p1 == i)
			{
				if (points[i].refcount == 1)
					break;			// all the other uses have been seperated
				line->p1 = [self allocatePoint: &points[i].pt];
				points[i].refcount--;
			}
			else if (line->p2 == i)
			{
				if (points[i].refcount == 1)
					break;			// all the other uses have been seperated
				line->p2 = [self allocatePoint: &points[i].pt];
				points[i].refcount--;
			}
		}
	}
	
	[self updateWindows];

	return self;
}

/*
===============
=
= cut:
=
===============
*/

- cut: sender
{

	[self updateWindows];
	return self;
}


/*
===============
=
= copy:
=
===============
*/

- copy: sender
{

	[self updateWindows];
	return self;
}


/*
===============
=
= paste:
=
===============
*/

- paste: sender
{

	[self updateWindows];
	return self;
}


/*
===============
=
= delete:
=
===============
*/

- delete: sender
{
	int	i;
	worldline_t	line;
	worldthing_t	thing;
	
// delete any lines that have both end points selected
	for (i=0 ; i<numlines ; i++)
	{
		if (lines[i].selected < 1)
			continue;
		if ( points[ lines[i].p1 ].selected != 1 ||  points[ lines[i].p2 ].selected != 1 )
			continue;
		line = lines[i];
		line.selected = -1;	// remove the line
		[self changeLine: i to: &line];
	}
	
// delete any selected things
	for (i=0 ; i<numthings ; i++)
		if ( things[ i].selected == 1)
		{
			thing = things[i];
			thing.selected = -1;	// remove the thing
			[self changeThing: i to: &thing];
		}

	[self updateWindows];
	return self;
}


/*
===============================================================================

						CHANGE METHODS
						
Updates dirty rect based on old and new positions

===============================================================================
*/

/*
====================
=
= changePoint: to:
=
====================
*/

- changePoint: (int) num to: (worldpoint_t *) data
{
	int	i;
	BOOL	moved;
	
//printf ("changePoint: %i\n",num);
	if (num < numpoints)		// can't get a dirty rect from a single new point
	{		
		if (data->pt.x == points[num].pt.x && data->pt.y == points[num].pt.y)
		{	// point's position didn't change
			[self addToDirtyRect: num : num];
			moved = NO;
		}
		else
		{
		// the dirty rect encloses all the lines that use the point, both before and after the move
			for (i=0 ; i<numlines ; i++)
				if (lines[i].p1 == num || lines[i].p2 == num)
					[self addToDirtyRect: lines[i].p1 : lines[i].p2];
			moved = YES;
		}
	}

	if (num >= numpoints)
	{
		NXRunAlertPanel ("Error","Sent point %i with numpoints %i!"
			,NULL,NULL,NULL, num, numpoints);
		[NXApp terminate:self];
	}
	
	points[num] = *data;

	if (moved) 
	{
		dirtypoints = true;		// connection matrix will need to be rebuilt
		for (i=0 ; i<numlines ; i++)
			if (lines[i].selected != -1 && ( lines[i].p1 == num || lines[i].p2 == num) )
			{
				[self addToDirtyRect: lines[i].p1 : lines[i].p2];
				[self updateLineNormal: i];
			}
	}
	
				

	return nil;
}

/*
====================
=
= changeLine: to:
=
= Updates midpoint / normal and dirty rect
=
====================
*/

- changeLine: (int) num to: (worldline_t *)data
{
//printf ("changeLine: %i\n",num);
	if (num >= numlines)
	{
		NXRunAlertPanel ("Error","Sent line %i with numlines %i!",NULL,NULL,NULL, num, numlines);
		[NXApp terminate:self];
	}
	
// mark the old position of the line as dirty
	if (lines[num].selected != -1)
		[self addToDirtyRect: lines[num].p1 : lines[num].p2];

// change the line	
	lines[num] = *data;
		
	if (data->selected != -1)
	{
	// mark the new position of the line as dirty
		[self addToDirtyRect: lines[num].p1 : lines[num].p2];
	// update midpoint / normal point
		[self updateLineNormal: num];
	}
	else
	{
	// drop point refcounts
		[self dropPointRefCount: lines[num].p1];
		[self dropPointRefCount: lines[num].p2];
	}

	return nil;
}


/*
====================
=
= changeThing: to:
=
====================
*/

- changeThing: (int)num to: (worldthing_t *)data
{
	NXRect	drect;
	
//printf ("changeThing: %i\n",num);
	if (num >= numthings)
	{
		NXRunAlertPanel ("Error","Sent thing %i with numthings %i!",NULL,NULL,NULL, num, numthings);
		[NXApp terminate:self];
	}
	
// mark the old position as dirty
	if (things[num].selected != -1)
	{
		NXSetRect (&drect, data->origin.x - THINGDRAWSIZE/2
		, data->origin.y - THINGDRAWSIZE/2,THINGDRAWSIZE, THINGDRAWSIZE);
		NXUnionRect (&drect, &dirtyrect);
	}

// change the thing	
	things[num] = *data;

// mark the new position as dirty
	if (things[num].selected != -1)
	{
		NXSetRect (&drect, data->origin.x - THINGDRAWSIZE/2
		, data->origin.y - THINGDRAWSIZE/2,THINGDRAWSIZE, THINGDRAWSIZE);
		NXUnionRect (&drect, &dirtyrect);
	}
	
	return nil;
}


/*
===============================================================================

						SELECTION METHODS

===============================================================================
*/


/*
================
=
= select/deselect Point / Line / Thing
=
================
*/

- selectPoint: (int)num
{
	worldpoint_t	*data;
	
	if (num >= numpoints)
	{
		printf ("selectPoint: num >= numpoints\n");
		return self;
	}
	data = &points[num];
	if (data->selected == -1)
	{
		printf ("selectPoint: deleted point\n");
		return self;
	}
	data->selected = 1;
	[self changePoint: num to:data];
	return self;
}


- deselectPoint: (int)num
{
	worldpoint_t	*data;
	
	if (num >= numpoints)
	{
		printf ("deselectPoint: num >= numpoints\n");
		return self;
	}
	data = &points[num];
	if (data->selected == -1)
	{
		printf ("deselectPoint: deleted\n");
		return self;
	}
	data->selected = 0;
	[self changePoint: num to:data];
	return self;
}


- selectLine: (int)num
{
	worldline_t	*data;
	
	if (num >= numlines)
	{
		printf ("selectLine: num >= numlines\n");
		return self;
	}
	data = &lines[num];
	if (data->selected == -1)
	{
		printf ("selectLine: deleted\n");
		return self;
	}
	data->selected = 1;
	[self changeLine: num to:data];
	return self;
}


- deselectLine: (int)num
{
	worldline_t	*data;
	
	if (num >= numlines)
	{
		printf ("deselectLines: num >= numliness\n");
		return self;
	}
	data = &lines[num];
	if (data->selected == -1)
	{
		printf ("deselectLine: deleted point\n");
		return self;
	}
	data->selected = 0;
	[self changeLine: num to:data];
	return self;
}


- selectThing: (int)num
{
	worldthing_t	*data;
	
	if (num >= numthings)
	{
		printf ("selectThing: num >= numthings\n");
		return self;
	}
	data = &things[num];
	if (data->selected == -1)
	{
		printf ("selectThing: deleted\n");
		return self;
	}
	data->selected = 1;
	[self changeThing: num to:data];
	return self;
}


- deselectThing: (int)num
{
	worldthing_t	*data;
	
	if (num >= numthings)
	{
		printf ("deselectThing: num >= numthings\n");
		return self;
	}
	data = &things[num];
	if (data->selected == -1)
	{
		printf ("deselectThing: deleted point\n");
		return self;
	}
	data->selected = 0;
	[self changeThing: num to:data];
	return self;
}



/*
=====================
=
= deselectAll???
=
=====================
*/

- deselectAllPoints
{
	int	p;	
	for (p=0; p<numpoints ; p++)
		if (points[p].selected > 0)
		{
			points[p].selected = 0;
			[self changePoint: p to: &points[p]];
		}
	return self;
}

- deselectAllLines
{
	int	p;
	for (p=0; p<numlines ; p++)
		if (lines[p].selected >0)
		{
			lines[p].selected = 0;
			[self changeLine: p to: &lines[p]];
		}
	return self;
}

- deselectAllThings
{
	int	p;
	for (p=0; p<numthings ; p++)
		if (things[p].selected > 0)
		{
			things[p].selected = 0;
			[self changeThing: p to: &things[p]];
		}
	return self;
}

- deselectAll
{
	[self deselectAllPoints];
	[self deselectAllLines];
	[self deselectAllThings];
	return self;
}



@end
