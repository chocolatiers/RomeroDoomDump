#import <libc.h>
#import "EditWorld.h"
#import "MapView.h"
#import "grouping.h"
#import "idfunctions.h"

byte	*connection = NULL;


/*
============
=
= IntersectLines
=
= Assumes that the bboxes allready have been intersected
=
============
*/

BOOL IntersectLines (NXPoint *p1, NXPoint *p2, NXPoint *p3, NXPoint *p4)
{
	box_t	box1, box2;
	float		slope, slope2, intercept, yintercept, yintercept2;
	float		xd1, yd1, xd2, yd2;
	
	BoxFromPoints (&box1, p1, p2);
	BoxFromPoints (&box2, p3, p4);
	
	xd1 = p2->x - p1->x;
	yd1 = p2->y - p1->y;
	xd2 = p4->x - p3->x;
	yd2 = p4->y - p3->y;

	if (box2.right < box1.left || box2.left >  box1.right
	|| box2.top < box1.bottom || box2.bottom > box1.top)
		return NO;		// bboxes don't intersect

	if (box1.left == box1.right)
	{
	//
	// box1 is a vertical line
	//
		if (box2. left == box2. right)
			return YES;
		if (box2. top == box2. bottom)
			return YES;			// intersecting

		// box2 is sloping
		slope = yd2 / xd2;
		intercept = p3->y - slope*(p3->x - p1->x);
		if (intercept < box1.bottom || intercept > box1.top)
			return NO;

		return YES;
	}

	if (box1.top == box1.bottom)
	{
	//
	// box1 is a horizontal line
	//
		if (box2. bottom == box2. top)
			return YES;			// overlapping
		if (box2. right == box2. left)
			return YES;			// intersecting
		// box2 is sloping
		slope = xd2 / yd2;
		intercept = p3->x - slope*(p3->y - p1->y);
		if (intercept < box1.left || intercept > box1.right)
			return NO;
			
		return YES;
	}

	//
	// box1 is a sloping line
	//
	
	if (box2. bottom == box2. top)
	{
	// box2 is horizontal
		slope = xd1 / yd1;
		intercept = p1->x - slope*(p1->y - p3->y);
		if (intercept < box2.left || intercept > box2.right)
			return NO;
		return YES;	
	}
	if (box2. right == box2. left)
	{
	// box2 is vertical
		slope = yd1 / xd1;
		intercept = p1->y - slope*(p1->x - p3->x);
		if (intercept < box2.bottom || intercept > box2.top)
			return NO;
		return YES;			// intersecting
	}
	// box2 is sloping
	slope = yd1 / xd1;
	slope2 = yd2 / xd2;
	yintercept = p1->y -slope*p1->x;
	yintercept2 = p3->y -slope2*p3->x;
	
	if (slope == slope2)
	{
	// parallel
		if (yintercept != yintercept2)
			return NO;	// paralell
		return YES;		// overlapping
	}
	
	intercept = (yintercept2- yintercept) / (slope - slope2);
	if (intercept < box1.left || intercept < box2.left ||
		intercept > box1.right || intercept > box2.right)
		return NO;
	return YES;	
}


/*
==================
=
= BuildConnectionMatrix
=
= Builds a table of connection values for all points in the world
=
= if connection[l1*numlines+l2]
= A point is considered NOT connected with itself, because the trace did not have to 
= cover any ground
=
===================
*/

void	BuildConnectionMatrix (void)
{
	NXPoint	*p1, *p2;
	int		i, l1,l2;
	id		pan;
	
//
// test everything for complete lines
//
	pan = NXGetAlertPanel ("One moment","Building connection matrix",NULL,NULL,NULL);
	[pan display];
	[pan orderFront: NULL];
	NXPing ();
	
	if (connection)
		connection = realloc(connection, numlines*numlines);
	else
		connection = malloc(numlines*numlines);
	memset (connection, 0, numlines*numlines);
		
	for (l1=0 ; l1<numlines-1 ; l1++)
	{
		if (lines[l1].selected == -1)
			continue;
		p1 = &lines[l1].mid;
		for (l2=l1+1 ; l2<numlines ; l2++)
		{
			if (lines[l2].selected == -1)
				continue;
			p2 = &lines[l2].mid;
		//
		// test all lines to see if they intercept the path from pn1 to pn2
		//
			
			for (i=0 ; i<numlines ; i++)
			{
				if (lines[i].selected == -1 || i== l1 || i== l2)
					continue;
				if (IntersectLines (p1, p2, &points[lines[i].p1].pt,&points[lines[i].p2].pt) )
					break;
			}
					
			connection[l1*numlines+l2] = (i == numlines);
			connection[l2*numlines+l1] = (i == numlines);
		}
	}

	NXFreeAlertPanel	(pan);
	NXPing ();
}


/*
==================
=
= LineSideToPoint
=
= Returns a 0 for front and a 1 for back
=
===================
*/

int	LineSideToPoint (worldline_t *line, NXPoint *pt)
{
	NXPoint	*p1, *p2;
	float		slope, yintercept;
	BOOL	direction, test;

	p1 = &points[line->p1].pt;
	p2 = &points[line->p2].pt;
	
	if (p1->y == p2->y)
		return (p1->x < p2->x) ^ (pt->y < p1->y);
	if (p1->x == p2->x)
		return (p1->y < p2->y) ^ (pt->x > p1->x);

	slope = (p2->y - p1->y) / (p2->x - p1->x);
	yintercept = p1->y - slope*p1->x;

//
// for y > mx+b, substitute in the normal point, which is on the front
//
	direction =  line->norm.y > slope*line->norm.x + yintercept ;
	test = pt->y > slope*pt->x + yintercept;
	
	if (direction == test)
		return 0;		// front side
	
	return 1;			// back side
}


/*
================
=
= IncludeLine
=
= Selects the line and recursively checks all other lines for 
=
================
*/

void IncludeLine (int num, int side)
{
	int		i, newside;
	byte		*connect;
	NXPoint	*newmid;
	worldline_t	*line;
	
	connect = &connection[num*numlines];
	
	line = &lines[num];
	newmid = &line->mid;
	
	line->selected = 1+side;
	points[line->p1].selected = 1;
	points[line->p2].selected = 1;

	for (i=0 ; i<numlines ; i++)
	{
		line = &lines[i];
		if (line->selected)
			continue;

		if (!connect[i])
			continue;			// line doesn't connect
			
		if (LineSideToPoint (&lines[num], &line->mid) != side)
			continue;			// test line is on back side of new line

		newside = LineSideToPoint (line, newmid);
		if (newside == 1 && ! (line->flags&ML_TWOSIDED) )
			continue;			// the new line is facing away
	//
	// recursively add the line
	//
		IncludeLine (i, newside);
	}
}


//=============================================================================

/*
================
=
= LineByPoint
=
= Returns the line and side closest (horizontally) to the point
= Returns -1 for line if no line is hit
=
================
*/

int LineByPoint (NXPoint *pt, int *side)
{
	int		l;
	NXPoint	*p1, *p2;
	float		frac, distance, bestdistance, xintercept;
	int		bestline;
	
	pt->x += 0.5;
	pt->y += 0.5;
		
//
// find the closest line to the given point
//
	bestdistance = MAXFLOAT;
	for (l=0 ; l<numlines ; l++)
	{
		if (lines[l].selected == -1)
			continue;
		
		p1 = &points[lines[l].p1].pt;
		p2 = &points[lines[l].p2].pt;
		
		if (p1->y == p2->y)
			continue;
			
		if (p1->y < p2->y)
		{
			frac = (pt->y - p1->y) / (p2->y - p1->y);
			if (frac<0 || frac>1)
				continue;
			xintercept = p1->x + frac*(p2->x - p1->x);
		}
		else
		{
			frac = (pt->y - p2->y) / (p1->y - p2->y);
			if (frac<0 || frac>1)
				continue;
			xintercept = p2->x + frac*(p1->x - p2->x);
		}
		
		distance = abs(xintercept - pt->x);
		if (distance < bestdistance)
		{
			bestdistance = distance;
			bestline = l;
		}
	}
	
//
// if no line is intercepted, the point was outside all areas
//
	if (bestdistance == MAXFLOAT)
		return -1;
		
	*side = LineSideToPoint (&lines[bestline], pt);

	return bestline;
}


/*
================
=
= SelectPlaneLinesAround
=
= Deselects all points and lines, then selects all the lines around the given point
=
================
*/

void SelectPlaneLinesAround (NXPoint *pt)
{
	int		bestline, bestside;
	
	pt->x += 0.5;
	pt->y += 0.5;
	
//
// deselect everything in the world
//
	[editworld_i deselectAll];
	
//
// find the closest line to the given point
//
	bestline = LineByPoint (pt, &bestside);
	
//
// if no line is intercepted, the point was outside all areas
//
	if (bestline == -1)
	{
		NXRunAlertPanel ("Error","No side line",NULL,NULL,NULL);
		[editworld_i redrawWindows];
		return;
	}
	
//
// if the closest side is a backside of a one sided wall, the point was
// not properly placed
//
	if ( !(lines[bestline].flags & ML_TWOSIDED)  && bestside == 1)
	{
		NXRunAlertPanel ("Error","Closest side is a backside",NULL,NULL,NULL);
		[editworld_i redrawWindows];
		return;
	}

//
// start connecting everything
//
	if ( [editworld_i dirtyPoints] )
		BuildConnectionMatrix ();
	IncludeLine (bestline, bestside);		// recursively add lines

	[editworld_i redrawWindows];
}


/*
==============
=
= DrawConnectionLines
=
// DEBUG
==============
*/

void DrawConnectionLines (void)
{
	worldline_t	tline;
	int			i,j, count;
	NXPoint		p1, p2;

	BuildConnectionMatrix ();
	
	memset (&tline, 0, sizeof(tline));
	tline.flags = ML_TWOSIDED;
	count = numlines;
	for (i=0 ; i<count ; i++)
	{
		p1 = lines[i].mid;
		for (j=i+1 ; j<count ; j++)
		{
			if (connection[i*count+j])
			{
				p2 = lines[j].mid;
				[editworld_i newLine: &tline from: &p1  to:&p2];
			}
		}
	}

	[editworld_i redrawWindows];
}

/*
==============================================================================

						SECTOR BUILDING

==============================================================================
*/

id		sectors=NULL;	// storage object of sectors
boolean	sectorerror;		// if true, the save will not complete

/*
================
=
= AddSideToSector
=
= Recursively adds all visible lines to the current sector
=
================
*/

void AddSideToSector (int num, int side, worldsector_t *sector)
{
	int			i, newside;
	worldline_t	*line;
	NXPoint	*newmid;
	byte		*connect;

//[editworld_i selectLine: num];
	
	connect = &connection[num*numlines];
	line = &lines[num];
	newmid = &line->mid;
	
//
// validate and add the line
//
	
	if (line->side[side].sector != -1)
	{
		sectorerror = true;
		printf ("line %i side %i grouped to multiple sectors\n", num, side);
		[editworld_i selectLine: num];
	}
	
	if (bcmp(&line->side[side].ends, &sector->s, sizeof(sectordef_t)) )
	{
		sectorerror = true;
		printf ("Line %i side %i has different sectordef than sectorstart\n", num, side);
		[editworld_i selectLine: num];
	}
	
	[sector->lines addElement: &num];
	line->side[side].sector = [sectors count]-1;
	
//
// recursively add all visible lines
//
	for (i=0 ; i<numlines ; i++)
	{
		line = &lines[i];
		if (line->selected == -1)
			continue;

		if (!connect[i])
			continue;			// line doesn't connect
			
		if (LineSideToPoint (&lines[num], &line->mid) != side)
			continue;			// test line is on back side of new line

		newside = LineSideToPoint (line, newmid);
		if (newside == 1 && ! (line->flags&ML_TWOSIDED) )
			continue;			// the new line is facing away
			
		if (line->side[newside].sector != -1)
			continue;		// allready grouped into a sector
			
	//
	// recursively add the line
	//
		AddSideToSector (i, newside, sector);
	}


}


/*
================
=
= BuildSector
=
= Creates a new sector and adds all visible lines to it
=
================
*/

void BuildSector (int line, int side)
{
	worldsector_t	new, *pos;
	
	memcpy (&new.s, &lines[line].side[side].ends, sizeof(sectordef_t));
	new.lines = [ [Storage alloc]
					initCount: 	0 
					elementSize: 	sizeof(int)
					description: 	NULL
				];
	
	[sectors addElement: &new];
	pos = [sectors elementAt: [sectors count]-1];
	
//[editworld_i deselectAll];
	AddSideToSector (line, side, pos);	// recursive
//[editworld_i updateWindows];
//NXRunAlertPanel ("Test","sector completed", NULL,NULL,NULL);

}


/*
================
=
= ConnectSectors
=
= Groups all lines into sectors, returns a storage object of worldends
=
================
*/

void ConnectSectors (void)
{
	int	i, j, count;
	worldline_t	*line;
	worldsector_t	*sector;
	
	if ( [editworld_i dirtyPoints] )
		BuildConnectionMatrix ();

	sectorerror = false;
	
//
// allocate or free up the sectors storage
//
	if (sectors == NULL)
		sectors = [[Storage alloc] 
					initCount: 	0 
					elementSize: 	sizeof(worldsector_t)
					description: 	NULL
				];
	else
	{
		count = [sectors count];
		for (i=0 ; i<count ; i++)
		{
			sector = [sectors elementAt: i];
			[sector->lines free];
		}
		
		[sectors empty];
	}
	
//
// mark all the line sides as unattched
//
	for (i=0 ; i<numlines ; i++)
	{
		lines[i].side[0].sector = -1;
		lines[i].side[1].sector = -1;
	}
		
//
// for all unattched line sides, start a new sector
//
	line = lines;
	for (i=0, line = lines ; i<numlines ; i++, line++)
	{
		if (line->selected == -1)
			continue;
		for (j=0 ; j<= (line->flags&ML_TWOSIDED)>0 ; j++)
			if (line->side[j].sector == -1)
				BuildSector (i, j);
	}
}



