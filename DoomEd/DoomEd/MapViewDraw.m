#import "MapViewDraw.h"
#import "idfunctions.h"
#import "EditWorld.h"
#import "PreferencePanel.h"
#import "pathops.h"
#import "Coordinator.h"
#import "ThingPanel.h"

@implementation MapView (MapViewDraw)

/*
===============================================================================

						DRAW SELF

===============================================================================
*/


/*
============
=
= drawGrid
=
= Draws tile markings every 64 units, and grid markings at the grid scale if the grid lines
= are at least 4 pixels apart
=
= Rect is in global world (unscaled) coordinates
=
============
*/

- drawGrid: (const NXRect *)rect
{
	int	x,y, stopx, stopy;
	float	top,bottom,right,left;

	left = rect->origin.x-1;
	bottom = rect->origin.y-1;
	right = rect->origin.x+rect->size.width+2;
	top = rect->origin.y+rect->size.height+2;

//
// grid
//
// can't just divide by grid size because of negetive coordinate truncating direction
//
	if (gridsize*scale >= 4)
	{
		y = floor(bottom/gridsize);
		stopy = floor(top/gridsize);
		x = floor(left/gridsize);
		stopx = floor(right/gridsize);
		
		y *= gridsize;
		stopy *= gridsize;
		x *= gridsize;
		stopx *= gridsize;
		if (y<bottom)
			y+= gridsize;
		if (x<left)
			x+= gridsize;
		if (stopx >= right)
			stopx -= gridsize;
		if (stopy >= top)
			stopy -= gridsize;
			
		StartPath (GRID_C);
		
		for ( ; y<=stopy ; y+= gridsize)
			if (y&63)
				AddLine (GRID_C, left, y, right, y);
	
		for ( ; x<=stopx ; x+= gridsize)
			if (x&63)
				AddLine (GRID_C, x, top, x, bottom);
	
		FinishPath (GRID_C);
	}

//
// tiles
//
	if (scale > 4.0/64)
	{
		y = floor(bottom/64);
		stopy = floor(top/64);
		x = floor(left/64);
		stopx = floor(right/64);
		
		y *= 64;
		stopy *= 64;
		x *= 64;
		stopx *= 64;
		if (y<bottom)
			y+= 64;
		if (x<left)
			x+= 64;
		if (stopx >= right)
			stopx -= 64;
		if (stopy >= top)
			stopy -= 64;
			
		StartPath (TILE_C);
		
		for ( ; y<=stopy ; y+= 64)
			AddLine (TILE_C, left, y, right, y);
	
		for ( ; x<=stopx ; x+= 64)
			AddLine (TILE_C, x, top, x, bottom);
	
		FinishPath (TILE_C);
	}

	return self;
}


/*
============
=
= drawLines
=
= Rect is in global world (unscaled) coordinates
= The user path routines automatically scale points by pathscale
============
*/

- drawLines: (const NXRect *)rect
{
	int		i,xc,yc;
	float		left,bottom,right, top;
	char		*clippoint;
	worldpoint_t	const	*wp;
	worldline_t	const	*li;
	int		color;
	
// classify all points on the currently displayed levels into 9 clipping regions
	clippoint = alloca (numpoints);

	left = rect->origin.x-1;
	bottom = rect->origin.y-1;
	right = rect->origin.x + rect->size.width+2;
	top = rect->origin.y + rect->size.height+2;
	
	wp = points;
	for (i=0 ; i<numpoints ; i++, wp++)
	{
		if (wp->selected == -1)
			continue;
			
		if (wp->pt.x < left)
			xc = 0;
		else if (wp->pt.x > right)
			xc = 2;
		else
			xc = 1;
		if (wp->pt.y < bottom)
			yc = 0;
		else if (wp->pt.y > top)
			yc = 2;
		else
			yc = 1;
		clippoint[i] = yc*3+xc;
	}
	
// set up user paths	
	StartPath (ONESIDED_C);
	StartPath (TWOSIDED_C);
	StartPath (SELECTED_C);
	StartPath (SPECIAL_C);
	
// only draw the lines that might intersect the visible rect

	li = lines;
	for (i=0 ; i<numlines ; i++, li++)
	{
		if (li->selected == -1)
			continue;		// deleted line
		if (!linecross[ clippoint[ li->p1] ][ clippoint[ li->p2] ])
			continue;			// line can't intersect the view
			
	// add a line to the path for it's type
		if (li->selected)
			color = SELECTED_C;
		else if (li->special)
			color = SPECIAL_C;
		else if (li->flags & ML_TWOSIDED)
			color = TWOSIDED_C;
		else
			color = ONESIDED_C;

if (points[li->p1].pt.x != points[li->p2].pt.x
|| points[li->p1].pt.y != points[li->p2].pt.y)
{
		AddLine (color, points[li->p1].pt.x,
						points[li->p1].pt.y,
						points[li->p2].pt.x,
						points[li->p2].pt.y);
		AddLine (color, li->mid.x, li->mid.y,li->norm.x, li->norm.y);
}
	}

	FinishPath (ONESIDED_C);
	FinishPath (TWOSIDED_C);
	FinishPath (SELECTED_C);
	FinishPath (SPECIAL_C);
	
	return self;
}

/*
============
=
= drawThings:
=
= Rect is in global world (unscaled) coordinates
============
*/

- drawThings: (const NXRect *)rect
{
	NXRect	r;
	float		offset;
	float		left, right, top, bottom;
	worldthing_t	*wp, *stop;
	int			diff;
	
	diff = [thingpanel_i	getDifficultyDisplay];
	offset = THINGDRAWSIZE;
	
	left = rect->origin.x - offset;
	right = rect->origin.x + rect->size.width + offset;
	bottom = rect->origin.y  - offset;
	top = rect->origin.y+ rect->size.height + offset;
	
	stop = things+numthings;
	
	for ( wp = things ; wp < stop ; wp++)
	{
		if (wp->selected == -1)
			continue;		// deleted thing
		if (wp->origin.x <left || 
			wp->origin.x > right || 
			wp->origin.y > top || 
			wp->origin.y < bottom)
			continue;
		
		// Only draw correct difficulties
		if (diff != DIFF_ALL)
			if (!((wp->options>>diff)&1))
				continue;
			
		if (wp->selected == 1)
			NXSetColor ([prefpanel_i colorFor: SELECTED_C]);
		else
			NXSetColor([thingpanel_i	getThingColor:wp->type]);
		r.origin.x = wp->origin.x - offset/2;
		r.origin.y = wp->origin.y - offset/2;
		r.size.width = r.size.height = offset;
		NXRectFill(&r);
	}

	return self;
}



/*
============
=
= drawPoints
=
= Rect is in global world (unscaled) coordinates
============
*/

- drawPoints: (const NXRect *)rect
{
	NXRect	*unselected, *selected, *unsel_p, *sel_p, *use;
	int		count;
	float		offset;
	float		left, right, top, bottom;
	worldpoint_t	const	*wp, *stop;
	
	unselected = unsel_p = alloca (numpoints*sizeof(NXRect));
	selected = sel_p = alloca (numpoints*sizeof(NXRect));
	
	offset = CPOINTDRAW/scale;
	
	left = rect->origin.x - offset;
	right = rect->origin.x + rect->size.width + offset;
	bottom = rect->origin.y  - offset;
	top = rect->origin.y+ rect->size.height + offset;
	
	stop = points+numpoints;
	
	for ( wp = points ; wp < stop ; wp++)
	{
		if (wp->selected == -1)
			continue;		// deleted point
		if (wp->pt.x <left || wp->pt.x > right || wp->pt.y > top || wp->pt.y < bottom)
			continue;
			
		if (wp->selected == 1)
			use = sel_p++;
		else
			use = unsel_p++;
		
		use->origin.x = wp->pt.x - offset/2;
		use->origin.y = wp->pt.y - offset/2;
		use->size.width = use->size.height = offset;
	}
	
//
// draw the rects
//
	count = unsel_p - unselected;
	if (count)
	{
		NXSetColor ([prefpanel_i colorFor: POINT_C]);
		NXRectFillList (unselected, count);
	}
	count = sel_p - selected;
	if (count)
	{
		NXSetColor ([prefpanel_i colorFor: SELECTED_C]);
		NXRectFillList (selected, count);
	}
	
	return self;
}


/*
====================
=
= drawSelf::
=
= Most of the time the rect will only be a small portion of the world
= The rect is in screen pixels, and should be divided by scale to get global
= world coordinates.  The translation of the origin is handled by postscript.
=
====================
*/
#define SHOWDISP	1

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	NXRect	newrect;
//printf ("drawself\n");
//
// erase to background color
//
#if 0
	if (rectCount == 3)
	{
	printf ("Rects: %f, %f, %f, %f\n", rects->origin.x, rects->origin.y, rects->size.width, rects->size.height);
	printf ("      1: %f, %f, %f, %f\n", rects[1].origin.x, rects[1].origin.y, rects[1].size.width, rects[1].size.height);
	printf ("      2: %f, %f, %f, %f\n", rects[2].origin.x, rects[2].origin.y, rects[2].size.width, rects[2].size.height);
	}
#endif

	if (!debugflag)
	{
		NXSetColor ([prefpanel_i colorFor: BACK_C]);
		NXRectFill (rects);
	}
	PSsetlinewidth (0.15);

	[self drawGrid: rects];	
	[self drawThings: rects];

// the draw size must be increased to cover any things that might have been overdrawn
// past the edges
	newrect = *rects;
	newrect.origin.x -= THINGDRAWSIZE;
	newrect.origin.y -= THINGDRAWSIZE;
	newrect.size.width += THINGDRAWSIZE*2;
	newrect.size.height += THINGDRAWSIZE*2;
	[self drawLines: &newrect];
	[self drawPoints: &newrect];
		
	if (debugflag)
	{
		NXSetColor (NXConvertRGBAToColor (0,0,1.0,0.1));
		PScompositerect (rects->origin.x, rects->origin.y, rects->size.width, rects->size.height, NX_SOVER);
	printf ("Rects: %f, %f, %f, %f\n", rects->origin.x, rects->origin.y, rects->size.width, rects->size.height);
	}

	return self;
}

@end

