// saveblocks.m

#import "doombsp.h"

short	datalist[0x10000], *data_p;
float	orgx, orgy;

#define	BLOCKSIZE	128


float		xl, xh, yl, yh;


boolean	LineContact (worldline_t *wl)
{
	NXPoint		*p1, *p2, pt1, pt2;
	float		lxl, lxh, lyl, lyh;
	divline_t	ld;
	int			s1,s2;
	
	p1 = &wl->p1;
	p2 = &wl->p2;
	ld.pt.x = p1->x;
	ld.pt.y = p1->y;
	ld.dx = p2->x - p1->x;
	ld.dy = p2->y - p1->y;
	
	if (p1->x < p2->x)
	{
		lxl = p1->x;
		lxh = p2->x;
	}
	else
	{
		lxl = p2->x;
		lxh = p1->x;
	}
	if (p1->y < p2->y)
	{
		lyl = p1->y;
		lyh = p2->y;
	}
	else
	{
		lyl = p2->y;
		lyh = p1->y;
	}

	if (lxl >= xh || lxh < xl || lyl >= yh || lyh < yl)		
		return false;	// no bbox intersections

	if ( ld.dy / ld.dx > 0)
	{	// positive slope
		pt1.x = xl;
		pt1.y = yh;
		pt2.x = xh;
		pt2.y = yl;
	}
	else
	{	// negetive slope
		pt1.x = xh;
		pt1.y = yh;
		pt2.x = xl;
		pt2.y = yl;
	}
	
	s1 = PointOnSide (&pt1, &ld);
	s2 = PointOnSide (&pt2, &ld);
	
	return s1 != s2;
}


/*
================
=
= GenerateBlockList
=
================
*/

void GenerateBlockList (int x, int y)
{
	NXRect		r;
	worldline_t	*wl;
	int			count, i;
	
	*data_p++ = 0;		// leave space for thing links
	
	xl = orgx + x*BLOCKSIZE;
	xh = xl+BLOCKSIZE;
	yl = orgy + y*BLOCKSIZE;
	yh = yl+BLOCKSIZE;
	
	r.origin.x = xl;
	r.origin.y = yl;
	r.size.width = r.size.height = BLOCKSIZE;
	if (draw)
		NXEraseRect (&r);
	
	count = [linestore_i count];
	wl = [linestore_i elementAt: 0];
	
	for (i=0 ; i<count ; i++,wl++)
	{
		if (wl->p1.x == wl->p2.x)
		{	// vertical
			if (wl->p1.x < xl || wl->p1.x >= xh)
				continue;
			if (wl->p1.y < wl->p2.y)
			{
				if (wl->p1.y >= yh || wl->p2.y < yl)
					continue;
			}
			else
			{
				if (wl->p2.y >= yh || wl->p1.y < yl)
					continue;
			}
			*data_p++ = SHORT(i);
			continue;
		}
		if (wl->p1.y == wl->p2.y)
		{	// horizontal
			if (wl->p1.y < yl || wl->p1.y >= yh)
				continue;
			if (wl->p1.x < wl->p2.x)
			{
				if (wl->p1.x >= xh || wl->p2.x < xl)
					continue;
			}
			else
			{
				if (wl->p2.x >= xh || wl->p1.x < xl)
					continue;
			}
			*data_p++ = SHORT(i);
			continue;
		}
		// diagonal
		if (LineContact (wl) ) 
			*data_p++ = SHORT(i);
	}
	
	*data_p++ = -1;		// end of list marker
}


/*
================
=
= SaveBlocks
=
block lump holds:
orgx
orgy
blockwidth
blockheight
listoffset[blockwidth*blockheight]
lists
	one short left blank for thing list
	linedef numbers
	-1 terminator
	
================
*/

void SaveBlocks (void)
{
	int		blockwidth, blockheight;
	int		x,y, len;
	short	*pointer_p;
	
	blockwidth = (worldbounds.size.width+BLOCKSIZE-1)/BLOCKSIZE;
	blockheight = (worldbounds.size.height+BLOCKSIZE-1)/BLOCKSIZE;
	orgx = worldbounds.origin.x;
	orgy = worldbounds.origin.y;
	
	pointer_p = datalist;
	*pointer_p++ = SHORT(orgx);
	*pointer_p++ = SHORT(orgy);
	*pointer_p++ = SHORT(blockwidth);
	*pointer_p++ = SHORT(blockheight);
	
	data_p = pointer_p + blockwidth*blockheight;
	
	for (y=0 ; y<blockheight ; y++)
		for (x=0 ; x<blockwidth ; x++)
		{
			len = data_p - datalist;
			*pointer_p++ = SHORT(len);
			GenerateBlockList (x,y);
		}
	
	len = 2*(data_p-datalist);
	
	printf ("blockmap: (%i, %i) = %i\n",blockwidth, blockheight, len);
	 
#if 0
{
	int	outhandle;
	
	outhandle = SafeOpenWrite ("blockmap.lmp");
	SafeWrite (outhandle, datalist, len);
	close (outhandle);
}
#endif
	[wad_i addName: "blockmap" data:datalist size:len];

}

