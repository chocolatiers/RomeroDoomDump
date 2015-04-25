// savebsp.m

#import "doombsp.h"

id		secstore_i;
id		mapvertexstore_i;
id		subsecstore_i;
id		maplinestore_i;
id		nodestore_i;
id		mapthingstore_i;
id		ldefstore_i;
id		sdefstore_i;

/*
===============================================================================

			the output functions byte swap and write lumps

===============================================================================
*/


/*
================
=
= WriteStorage
=
================
*/

void WriteStorage (char *name, id store, int esize)
{
	int		count, len;
	
	count = [store count];
	len = esize*count;
	[wad_i addName: name data:[store elementAt:0] size:len];
	printf ("%s (%i): %i\n",name,count,len);	
}


/*
=================
=
= OutputSectors
=
=================
*/

void OutputSectors (void)
{
	int		i, count;
	mapsector_t		*p;

	count = [secstore_i count];
	p = [secstore_i elementAt:0];
	for (i=0 ; i<count ; i++, p++)
	{
		p->floorheight = SHORT(p->floorheight);
		p->ceilingheight = SHORT(p->ceilingheight);
		p->lightlevel = SHORT(p->lightlevel);
		p->special = SHORT(p->special);
		p->tag = SHORT(p->tag);
	}	
	WriteStorage ("sectors", secstore_i, sizeof(mapsector_t));
}
 
 
/*
=================
=
= OutputSegs
=
=================
*/

void OutputSegs (void)
{
	int		i, count;
	mapseg_t		*p;

	count = [maplinestore_i count];
	p = [maplinestore_i elementAt:0];
	for (i=0 ; i<count ; i++, p++)
	{
		p->v1 = SHORT(p->v1);
		p->v2 = SHORT(p->v2);
		p->angle = SHORT(p->angle);
		p->linedef = SHORT(p->linedef);
		p->side = SHORT(p->side);
		p->offset = SHORT(p->offset);
	}	
	WriteStorage ("segs",maplinestore_i, sizeof(mapseg_t));
}


/*
=================
=
= OutputSubsectors
=
=================
*/

void OutputSubsectors (void)
{
	int		i, count;
	mapsubsector_t		*p;

	count = [subsecstore_i count];
	p = [subsecstore_i elementAt:0];
	for (i=0 ; i<count ; i++, p++)
	{
		p->numsegs = SHORT(p->numsegs);
		p->firstseg = SHORT(p->firstseg);
	}	
	WriteStorage ("ssectors", subsecstore_i, sizeof(mapsubsector_t));
}


/*
=================
=
= OutputVertexes
=
=================
*/

void OutputVertexes (void)
{
	int		i, count;
	mapvertex_t		*p;

	count = [mapvertexstore_i count];
	p = [mapvertexstore_i elementAt:0];
	for (i=0 ; i<count ; i++, p++)
	{
		p->x = SHORT(p->x);
		p->y = SHORT(p->y);
	}	
	WriteStorage ("vertexes",mapvertexstore_i, sizeof(mapvertex_t));
}


/*
=================
=
= OutputThings
=
=================
*/

void OutputThings (void)
{
	int		i, count;
	mapthing_t		*p;

	count = [mapthingstore_i count];
	p = [mapthingstore_i elementAt:0];
	for (i=0 ; i<count ; i++, p++)
	{
		p->x = SHORT(p->x);
		p->y = SHORT(p->y);
		p->angle = SHORT(p->angle);
		p->type = SHORT(p->type);
		p->options = SHORT(p->options);
	}	
	WriteStorage ("things", mapthingstore_i, sizeof(mapthing_t));
}


/*
=================
=
= OutputLineDefs
=
=================
*/

void OutputLineDefs (void)
{
	int		i, count;
	maplinedef_t		*p;

	count = [ldefstore_i count];
	p = [ldefstore_i elementAt:0];
	for (i=0 ; i<count ; i++, p++)
	{
		p->v1 = SHORT(p->v1);
		p->v2 = SHORT(p->v2);
// some ancient version of DoomEd left ML_MAPPED flags in some of the levels
		p->flags = SHORT(p->flags&~ML_MAPPED);
		p->special = SHORT(p->special);
		p->tag = SHORT(p->tag);
		p->sidenum[0] = SHORT(p->sidenum[0]);
		p->sidenum[1] = SHORT(p->sidenum[1]);
	}	
	WriteStorage ("linedefs", ldefstore_i, sizeof(maplinedef_t));
}


/*
=================
=
= OutputSideDefs
=
=================
*/

void OutputSideDefs (void)
{
	int		i, count;
	mapsidedef_t		*p;

	count = [sdefstore_i count];
	p = [sdefstore_i elementAt:0];
	for (i=0 ; i<count ; i++, p++)
	{
		p->textureoffset = SHORT(p->textureoffset);
		p->rowoffset = SHORT(p->rowoffset);
		p->sector = SHORT(p->sector);
	}	
	WriteStorage ("sidedefs", sdefstore_i, sizeof(mapsidedef_t));
}


/*
=================
=
= OutputNodes
=
=================
*/

void OutputNodes (void)
{
	int		i, j, count;
	mapnode_t		*p;

	count = [nodestore_i count];
	p = [nodestore_i elementAt:0];
	for (i=0 ; i<count ; i++, p++)
	{
		for (j=0 ; j<sizeof(mapnode_t)/2 ; j++)
			((short *)p)[j] = SHORT(((short *)p)[j]);
	}	
	WriteStorage ("nodes", nodestore_i, sizeof(mapnode_t));
}


/*
===============================================================================

							PROCESSING

===============================================================================
*/


/*
=================
=
= UniqueVertex
=
= Returns the vertex number, adding a new vertex if needed 
=================
*/

int UniqueVertex (int x, int y)
{
	int				i, count;
	mapvertex_t		mv, *mvp;
	
	mv.x = x;
	mv.y = y;
	
// see if an identical vertex already exists
	count = [mapvertexstore_i count];
	mvp = [mapvertexstore_i elementAt:0];
	for (i=0 ; i<count ; i++, mvp++)
		if (mvp->x == mv.x && mvp->y == mv.y)
			return i;

	[mapvertexstore_i addElement: &mv];
	
	return count;	
}


//=============================================================================


float	bbox[4];

/*
=================
=
= AddPointToBBox
=
=================
*/

void AddPointToBBox (NXPoint *pt)
{
	if (pt->x < bbox[BOXLEFT])
		bbox[BOXLEFT] = pt->x;
	if (pt->x > bbox[BOXRIGHT])
		bbox[BOXRIGHT] = pt->x;
		
	if (pt->y > bbox[BOXTOP])
		bbox[BOXTOP] = pt->y;
	if (pt->y < bbox[BOXBOTTOM])
		bbox[BOXBOTTOM] = pt->y;
}


/*
=================
=
= ProcessLines
=
= Adds the lines in a subsector to the mapline storage
=================
*/

void ProcessLines (id store_i)
{
	int			i,count;
	line_t 		*wline;
	mapseg_t	line;
	short		angle;
	float		fangle;
	
	bbox[BOXLEFT] = MAXINT;
	bbox[BOXRIGHT] = MININT;
	bbox[BOXTOP] = MININT;
	bbox[BOXBOTTOM] = MAXINT;
	
	count = [store_i count];
	for (i=0 ; i<count ; i++)
	{
		wline = [store_i elementAt: i];
		if (wline->grouped)
			printf ("ERROR: line regrouped\n");
		wline->grouped = true;
		
		memset (&line, 0, sizeof(line));
		AddPointToBBox (&wline->p1);
		AddPointToBBox (&wline->p2);
		line.v1 = UniqueVertex (wline->p1.x, wline->p1.y);
		line.v2 = UniqueVertex (wline->p2.x, wline->p2.y);
		line.linedef = wline->linedef;
		line.side = wline->side;
		line.offset = wline->offset;
		fangle = atan2 (wline->p2.y - wline->p1.y, wline->p2.x - wline->p1.x);
		angle = (short)(fangle/(PI*2)*0x10000);
		line.angle = angle;
		[maplinestore_i addElement: &line];
	}
}


/*
=================
=
= ProcessSubsector
=
=================
*/

int ProcessSubsector (id wmaplinestore_i)
{
	int				count;
	worldline_t		*linedef;
	line_t			*wline;
	mapsubsector_t	sub;
	
	memset (&sub,0,sizeof(sub));
	
	count = [wmaplinestore_i count];
	if (count < 1)
		Error ("ProcessSubsector: count = %i",count);
		
	wline = [wmaplinestore_i elementAt: 0];
	
	linedef = [linestore_i elementAt: wline->linedef];
	sub.numsegs = count;
	sub.firstseg = [maplinestore_i count];
	ProcessLines (wmaplinestore_i);
	
// add the new subsector
	[subsecstore_i addElement: &sub];
	
	return [subsecstore_i count]-1;
}

/*
=================
=
= ProcessNode
=
=================
*/

int ProcessNode (bspnode_t *node, short *totalbox)
{
	short		subbox[2][4];
	int			i, r;
	mapnode_t	mnode;
	
	memset (&mnode,0,sizeof(mnode));

	if (node->lines_i)	// NF_SUBSECTOR flags a subsector
	{
		r = ProcessSubsector (node->lines_i);
		for (i=0 ; i<4 ; i++)
			totalbox[i] = bbox[i];
		return r | NF_SUBSECTOR;
	}
	
	mnode.x =node->divline.pt.x;
	mnode.y =node->divline.pt.y;
	mnode.dx =node->divline.dx;
	mnode.dy =node->divline.dy;
	
	r = ProcessNode(node->side[0], subbox[0]);
	mnode.children[0] =r;
	for (i=0 ; i<4 ; i++)
		mnode.bbox[0][i] =subbox[0][i];
	
	r = ProcessNode (node->side[1],subbox[1]);
	mnode.children[1] =r;
	for (i=0 ; i<4 ; i++)
		mnode.bbox[1][i] =subbox[1][i];

	totalbox[BOXLEFT] = MIN(subbox[0][BOXLEFT], subbox[1][BOXLEFT]);
	totalbox[BOXTOP] = MAX(subbox[0][BOXTOP], subbox[1][BOXTOP]);
	totalbox[BOXRIGHT] = MAX(subbox[0][BOXRIGHT], subbox[1][BOXRIGHT]);
	totalbox[BOXBOTTOM] = MIN(subbox[0][BOXBOTTOM], subbox[1][BOXBOTTOM]);
	
	[nodestore_i addElement: &mnode];
	return [nodestore_i count] - 1;	
}


/*
=================
=
= ProcessNodes
=
= Recursively builds the nodes, subsectors, and line lists,
= then writes the lumps
=================
*/

void ProcessNodes (void)
{
	short	worldbounds[4];
	
	subsecstore_i = [[Storage alloc]
		initCount:		0
		elementSize:	sizeof(mapsubsector_t)
		description:	NULL];
	maplinestore_i = [[Storage alloc]
		initCount:		0
		elementSize:	sizeof(mapseg_t)
		description:	NULL];
	nodestore_i = [[Storage alloc]
		initCount:		0
		elementSize:	sizeof(mapnode_t)
		description:	NULL];

	ProcessNode (startnode, worldbounds);

}


/*
=================
=
= ProcessThings
=
=================
*/

void ProcessThings (void)
{
	worldthing_t	*wt;
	mapthing_t		mt;
	int				count;
	
	mapthingstore_i = [[Storage alloc]
		initCount:		0
		elementSize:	sizeof(mapthing_t)
		description:	NULL];

	count = [thingstore_i count];
	wt = [thingstore_i elementAt: 0];

	while (count--)
	{	 
		memset (&mt,0,sizeof(mt));
		mt.x =wt->origin.x;
		mt.y =wt->origin.y;
		mt.angle =wt->angle;
		mt.type =wt->type;
		mt.options =wt->options;
		[mapthingstore_i addElement: &mt];
		wt++;
	}
	
}

//=============================================================================


/*
==================
=
= ProcessSidedef
=
==================
*/

int ProcessSidedef (worldside_t *ws)
{
	mapsidedef_t	ms;
	
	ms.textureoffset = ws->firstcollumn;
	ms.rowoffset = ws->firstrow;
	memcpy (ms.toptexture, ws->toptexture, 8);
	memcpy (ms.bottomtexture, ws->bottomtexture, 8);
	memcpy (ms.midtexture, ws->midtexture, 8);
	ms.sector = ws->sector;
	
	[sdefstore_i addElement: &ms];
	return [sdefstore_i count]-1;
}

/*
==================
=
= ProcessLineSideDefs
=
= Must be called after BuildSectors
==================
*/

void ProcessLineSideDefs (void)
{
	int				i, count;
	maplinedef_t	ld;
	worldline_t		*wl;
	
	mapvertexstore_i = [[Storage alloc]
		initCount:		0
		elementSize:	sizeof(mapvertex_t)
		description:	NULL];
	ldefstore_i = [[Storage alloc]
		initCount:		0
		elementSize:	sizeof(maplinedef_t)
		description:	NULL];
	sdefstore_i = [[Storage alloc]
		initCount:		0
		elementSize:	sizeof(mapsidedef_t)
		description:	NULL];

	count = [linestore_i count];
	wl = [linestore_i elementAt:0];
	for (i=0 ; i<count ; i++, wl++)
	{
		ld.v1 = UniqueVertex(wl->p1.x,wl->p1.y);
		ld.v2 =UniqueVertex(wl->p2.x,wl->p2.y);
		ld.flags =wl->flags;
		ld.special =wl->special;
		ld.tag =wl->tag;
		ld.sidenum[0] =ProcessSidedef(&wl->side[0]);
		if (wl->flags & ML_TWOSIDED)
			ld.sidenum[1] =ProcessSidedef(&wl->side[1]);
		else
			ld.sidenum[1] =-1;
		[ldefstore_i addElement: &ld];
	}
	
}

//=============================================================================

/*
==================
=
= SaveDoomMap
=
==================
*/

void SaveDoomMap (void)
{
	BuildSectordefs ();
	ProcessThings ();
	ProcessLineSideDefs ();
	ProcessNodes ();
	ProcessSectors ();
	ProcessConnections ();
	
// all processing is complete, write everything out
	OutputThings ();
	OutputLineDefs ();
	OutputSideDefs ();
	OutputVertexes ();
	OutputSegs ();
	OutputSubsectors ();
	OutputNodes ();
	OutputSectors ();
}

