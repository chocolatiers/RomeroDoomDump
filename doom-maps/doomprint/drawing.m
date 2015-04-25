// drawing.m
#import "doombsp.h"

id 			window_i, view_i;
float		scale = 0.125;
NXRect		worldbounds;

/*
===========
=
= BoundLineStore
=
===========
*/

void BoundLineStore (id lines_i, NXRect *r)
{
	int				i,c;
	worldline_t		*line_p;
	
	c = [lines_i count];
	if (!c)
		Error ("BoundLineStore: empty list");
		
	line_p = [lines_i elementAt:0];
	IDRectFromPoints (r, &line_p->p1, &line_p->p2);
	
	for (i=1 ; i<c ; i++)
	{
		line_p = [lines_i elementAt:i];
		IDEnclosePoint (r, &line_p->p1);
		IDEnclosePoint (r, &line_p->p2);
	}	
}


/*
===========
=
= DrawLineStore
=
= Draws all of the lines in the given storage object
=
===========
*/

void DrawLineStore (id lines_i)
{
	int				i,c;
	worldline_t		*line_p;
	
	if (!draw)
		return;
		
	c = [lines_i count];
	
	for (i=0 ; i<c ; i++)
	{
		line_p = [lines_i elementAt:i];
		PSmoveto (line_p->p1.x, line_p->p1.y);
		PSlineto (line_p->p2.x, line_p->p2.y);
		PSstroke ();
	}
	NXPing ();
}

/*
===========
=
= DrawLine
=
= Draws all of the lines in the given storage object
=
===========
*/

void DrawLineDef (maplinedef_t *ld)
{
	mapvertex_t		*v1, *v2;
	
	if (!draw)
		return;
	
	v1 = [mapvertexstore_i elementAt: ld->v1];
	v2 = [mapvertexstore_i elementAt: ld->v2];
		
	PSmoveto (v1->x, v1->y);
	PSlineto (v2->x, v2->y);
	PSstroke ();
	NXPing ();
}


/*
===========
=
= DrawMap
=
===========
*/

void DrawMap (void)
{
	NXRect	scaled;
	
	BoundLineStore (linestore_i, &worldbounds);
	worldbounds.origin.x -= 8;
	worldbounds.origin.y -= 8;
	worldbounds.size.width += 16;
	worldbounds.size.height += 16;
	
	if (!draw)
		return;
		
	scaled.origin.x = 300;
	scaled.origin.y = 80;
	scaled.size.width = worldbounds.size.width*scale;
	scaled.size.height = worldbounds.size.height* scale;
	
	window_i =
	[[Window alloc]
		initContent:	&scaled
		style:			NX_TITLEDSTYLE
		backing:		NX_RETAINED
		buttonMask:		0
		defer:			NO
	];
	
	[window_i display];
	[window_i orderFront: nil];
	view_i = [window_i contentView];
	
	[view_i
		setDrawSize:	worldbounds.size.width
		:				worldbounds.size.height];
	[view_i 
		setDrawOrigin:	worldbounds.origin.x 
		: 				worldbounds.origin.y];
			
	[view_i lockFocus];
	PSsetgray (NX_BLACK);	
	DrawLineStore (linestore_i);
}


/*
===========
=
= EraseWindow
=
===========
*/

void EraseWindow (void)
{
	NXEraseRect (&worldbounds);
	NXPing ();
}


/*
============================
=
= DrawDivLine
=
============================
*/

void DrawDivLine (divline_t *div)
{
	float	vx,vy, dist;
	
	if (!draw)
		return;
		
	PSsetgray (NX_BLACK);
	
	dist = sqrt (pow(div->dx,2)+pow(div->dy,2));
	vx = div->dx/dist;
	vy = div->dy/dist;
	
	dist = MAX(worldbounds.size.width,worldbounds.size.height);
	
	PSmoveto (div->pt.x - vx*dist, div->pt.y - vy*dist);
	PSlineto (div->pt.x + vx*dist, div->pt.y + vy*dist);
	PSstroke ();
	NXPing ();
}

