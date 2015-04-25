#import <math.h>
#import "idfunctions.h"
#import "EditWorld.h"

@implementation EditWorld (EWLoadSave)

/*
=================
=
= read/writeLine
=
=================
*/

- (BOOL)readLine: (NXPoint *)p1 : (NXPoint *)p2 : (worldline_t *)line from: (FILE *)file
{
	worldside_t	*s;
	sectordef_t	*e;
	int			i;

	memset (line, 0, sizeof(*line));

	if (fscanf (file,"(%f,%f) to (%f,%f) : %d : %d : %d\n"
		,&p1->x, &p1->y,&p2->x, &p2->y,&line->flags, &line->special, &line->tag) != 7)
		return NO;
	
	for (i=0 ; i<=  ( (line->flags&ML_TWOSIDED) != 0) ; i++)
	{
		s = &line->side[i];	
		if (fscanf (file,"    %d (%d : %s / %s / %s )\n"
			,&s->flags, &s->firstcollumn, s->toptexture, s->bottomtexture, s->midtexture) != 5)
			return NO;
		e = &s->ends;
		if (fscanf (file,"    %d : %s %d : %s %d %d %d\n"
			,&e->floorheight, e->floorflat, &e->ceilingheight
			,e->ceilingflat,&e->lightlevel, &e->special, &e->tag) != 7)
			return NO;
	}

	return YES;
}

- writeLine: (worldline_t *)line to: (FILE *)file
{
	worldside_t	*s;
	sectordef_t	*e;
	int			i;
	
	fprintf (file,"(%d,%d) to (%d,%d) : %d : %d : %d\n"
		,(int)points[line->p1].pt.x, (int)points[line->p1].pt.y
		,(int)points[line->p2].pt.x, (int)points[line->p2].pt.y
		,line->flags, line->special, line->tag);
	
	for (i=0 ; i<=  ( (line->flags&ML_TWOSIDED) != 0) ; i++ )
	{
		s = &line->side[i];
		if (!strlen (s->toptexture))
			strcpy (s->toptexture, "-");
		if (!strlen (s->midtexture))
			strcpy (s->midtexture, "-");
		if (!strlen (s->bottomtexture))
			strcpy (s->bottomtexture, "-");
		if (!strlen (s->ends.floorflat))
			strcpy (s->ends.floorflat, "-");
		if (!strlen (s->ends.ceilingflat))
			strcpy (s->ends.ceilingflat, "-");
		s = &line->side[i];	
		fprintf (file,"    %d (%d : %s / %s / %s )\n"
			,s->flags, s->firstcollumn, s->toptexture, s->bottomtexture, s->midtexture);
		e = &s->ends;
		fprintf (file,"    %d : %s %d : %s %d %d %d\n"
			,e->floorheight, e->floorflat, e->ceilingheight, e->ceilingflat
			, e->lightlevel, e->special, e->tag);
	}

	return self;
}

/*
=================
=
= read/writeThing
=
=================
*/

- (BOOL)readThing: (worldthing_t *)thing from: (FILE *)file
{
	int	x,y;
	
	memset (thing, 0, sizeof(*thing));

	if (fscanf (file,"(%i,%i, %d) :%d, %d\n"
		,&x, &y, &thing->angle, &thing->type, &thing->options) != 5)
		return NO;

	thing->origin.x = x & -16;
	thing->origin.y = y & -16;
//	thing->options = 0x07;
	
	return YES;
}

- writeThing: (worldthing_t *)thing to: (FILE *)file
{
	int		x,y;
	
	x = (int)(thing->origin.x);
	y = (int)(thing->origin.y);
	
	fprintf (file,"(%d,%d, %d) :%d, %d\n"
		,x, y, thing->angle,thing->type, thing->options);

	return self;
}


/*
=============================================================================

						LOAD / SAVE TO DISK FILE

=============================================================================
*/



/*
===================
=
= saveFile
=
===================
*/

- saveFile: (FILE *)file
{
	int	i, count;
	
	fprintf (file, "WorldServer version 4\n");

//
// lines
//	
	count = 0;
	for (i=0 ; i<numlines ; i++)
		if (lines[i].selected != -1)
			count++;

	fprintf (file,"\nlines:%d\n", count);
	for (i=0 ; i<numlines ; i++)
		if (lines[i].selected != -1)
			[self writeLine: &lines[i] to: file];
		
//
// things
//
	count = 0;
	for (i=0 ; i<numthings ; i++)
		if (things[i].selected != -1)
			count++;
			
	fprintf (file,"\nthings:%d\n",count);
	for (i=0 ; i<numthings ; i++)
		if (things[i].selected != -1)
			[self writeThing: &things[i] to: file];
	

	return self;
}


/*
===================
=
= loadV4File
=
===================
*/

- loadV4File: (FILE *)file
{
	int			i;
	int			linecount, thingcount;
	NXPoint		p1, p2;
	worldline_t	line;
	worldthing_t	thing;	
	
	printf ( "Loading version 4 file\n");
		
//
// read lines
//	
	if (fscanf (file,"\nlines:%d\n",&linecount) != 1)
		return nil;
	printf ("%i lines\n", linecount);
	for (i=0 ; i<linecount ; i++)
	{
		if (![self readLine: &p1 : &p2 : &line from: file])
			return nil;
		[self newLine: &line from: &p1 to: &p2];
	}
		
//
// read things
//
	if (fscanf (file,"\nthings:%d\n",&thingcount) != 1)
		return nil;
	printf ( "%i things\n", thingcount);
	for (i=0 ; i<thingcount ; i++)
	{
		if (![self readThing: &thing from: file])
			return nil;
		[self newThing: &thing];
	}


	return self;
}



@end

