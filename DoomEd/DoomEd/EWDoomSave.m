#import "idfunctions.h"
#import "Wadfile.h"
#import "EditWorld.h"
#import "R_mapdef.h"
#import "DoomProject.h"
#import "BlockWorld.h"
#import "TextLog.h"

typedef struct
{
	char	identification[4];		// should be IWAD
	int		numlumps;
	int		infotableofs;
} wadinfo_t;


@implementation EditWorld (EWDoomSave)

char		*buffer, *buf_p;
int		worldsize;

id		mapwad_i;

// the writeplanenames / writepatchnames methods build these translation tables
int		lumptoflatnum[4096];
int		pointcrunch[8192];
int		linecrunch[8192];

/*
===============================================================================

						SAVE OUTPUT FILE

===============================================================================
*/

	
/*
================
=
= writeBuffer
=
================
*/

- writeBuffer: (char const *)filename
{
	int		size;
	
	size = buf_p - buffer;
	[mapwad_i addName: filename data: buffer size: size];
	printf ("%s:  %i bytes\n", filename, size);
	worldsize += size;
		
	return self;
}



/*
================
=
= writeFlatNames
=
================
*/

- writeFlatNames
{
	int	lump, count, i,j;
	worldline_t	*line;

//
// write out names of wall patches used
//
	count = 0;
	buf_p = buffer + 4;
	memset (lumptoflatnum, -1, sizeof(lumptoflatnum));
	
	for (i=0 ; i<numlines ; i++)
	{
		line = &lines[i];
		if (line->selected == -1)
			continue;
		for (j=0 ; j<=  ( (line->flags&ML_TWOSIDED) != 0 ) ; j++ )
		{
			lump = [wadfile_i lumpNamed : line->side[j].ends.floorflat];
			if (lumptoflatnum[lump] == -1)
			{
				memcpy (buf_p, line->side[j].ends.floorflat,8);
				buf_p += 8;
				lumptoflatnum[lump] = count;
				count++;
			}
			lump = [wadfile_i lumpNamed : line->side[j].ends.ceilingflat];
			if (lumptoflatnum[lump] == -1)
			{
				memcpy (buf_p, line->side[j].ends.ceilingflat,8);
				buf_p += 8;
				lumptoflatnum[lump] = count;
				count++;
			}
		}
	}
			
	*(int *)buffer = LongSwap (count);
	[self writeBuffer: "flatname"];
			
	return self;
}

/*
================
=
= writePoints
=
================
*/

- writePoints
{
	int			i;
	int			count;
	mapvertex_t	*vertex;
	
	count = 0;
	memset (pointcrunch, 0, sizeof(pointcrunch));
	buf_p = buffer + 4;	
	
	for (i= 0 ; i<numpoints ; i++)
	{
		if (points[i].selected == -1)
			continue;
		pointcrunch[i] = count;
		count++;
		vertex = (mapvertex_t *)buf_p;
		buf_p += sizeof(mapvertex_t);
		vertex->x = ShortSwap( (int)(points[i].pt.x ));
		vertex->y = ShortSwap ((int)(points[i].pt.y));
	}

	*(int *)buffer = LongSwap (count);
	[self writeBuffer: "points"];

	return self;
}


/*
================
=
= writeLines
=
================
*/

- writeLines
{
	int		i, s,  top, bottom, height;
	int		ttex, mtex, btex;
	worldline_t	*wline;
	mapline_t	*line;
	mapside_t	*side;
	worldside_t	*wside;
	int		count;
	int		length;
	float		dx, dy;
	NXPoint	*p1, *p2;
	char		string[80];
	
	count = 0;

//
// write out the lines
//
	buf_p = buffer+4;
	
	for (i= 0 ; i<numlines ; i++)
	{
		wline = &lines[i];
		if (wline->selected != -1)
		{
			linecrunch[i] = count;
			count++;

			line = (mapline_t *)buf_p;
			buf_p += sizeof(mapline_t);
							
			line->p1 = ShortSwap (pointcrunch[wline->p1]);
			line->p2 = ShortSwap (pointcrunch[wline->p2]);
			line->flags = ShortSwap (wline->flags);
			line->special = ShortSwap( wline->special);
			line->tag = ShortSwap( wline->tag);
			p1 = &points[wline->p1].pt;
			p2 = &points[wline->p2].pt;
			
			dx = p2->x - p1->x;
			dy = p2->y - p1->y;
			length = sqrt(dx*dx + dy*dy);
			line->length = ShortSwap (length);
			
			for (s=0 ; s<=  ( (wline->flags&ML_TWOSIDED) != 0) ; s++ )
			{
				wside = &wline->side[s];
				side = &line->side[s];
				
				if (wside->ends.floorheight > wside->ends.ceilingheight)
				{
					[editworld_i selectLine: i];
					sprintf( string, "LINE %d ERROR: Floor higher than ceiling!\n",i );
					[log_i	msg:string ];
				}
					
				side->flags = ShortSwap (wside->flags);
				side->firstcollumn = ShortSwap (wside->firstcollumn);
				
				ttex =  [doomproject_i textureNamed: wside->toptexture];
				if (ttex == -2)
				{
					[editworld_i selectLine: i];
					sprintf( string, "LINE %d ERROR: "
						"Can't find top texture '%s'!\n",i,wside->toptexture);
					[log_i	msg:string ];
				}
				side->toptexture = ShortSwap (ttex);
				btex =  [doomproject_i textureNamed: wside->bottomtexture];
				if (btex == -2)
				{
					[editworld_i selectLine: i];
					sprintf( string, "LINE %d ERROR: "
						"Can't find bottom texture '%s'!\n",i,wside->bottomtexture);
					[log_i	msg:string ];
				}
				side->bottomtexture = ShortSwap (btex);
				mtex =  [doomproject_i textureNamed: wside->midtexture];
				if (mtex == -2)
				{
					[editworld_i selectLine: i];
					sprintf( string, "LINE %d ERROR: "
						"Can't find middle texture '%s'!\n",i,wside->midtexture);
					[log_i	msg:string ];
				}
				side->midtexture = ShortSwap (mtex);
				
				side->sector = ShortSwap (wside->sector);

				if ( wline->flags & ML_TWOSIDED )
				{	// validate two sided wall
					top = wline->side[s].ends.ceilingheight;
					bottom = wline->side[!s].ends.ceilingheight;
					height = top - bottom;
//					if ( height > 0 &&  ( ttex < 0 || textures[ttex].height < height) )
//						[editworld_i selectLine: i];  // not enough top texture
					top = wline->side[!s].ends.floorheight;
					bottom = wline->side[s].ends.floorheight;
					height = top - bottom;
//					if (height > 0 && ( btex < 0 || textures[btex].height < height) )
//						[editworld_i selectLine: i];  // not enough bottom texture
					if (mtex != -1)
					{
						[editworld_i selectLine: i]; // FIXME: until mid textures work
						sprintf(string,"LINE %d: Two-sided line has a midtexture!\n",i);
						[log_i	msg:string];
					}
				}
				else
				{	// validate single sided wall
					top = wside->ends.ceilingheight;
					bottom = wside->ends.floorheight;
//					if (mtex < 0 || top - bottom >  textures[mtex].height)
//						[editworld_i selectLine: i];  // not enough middle texture
				}


			}
		}
	}

	*(int *)buffer = LongSwap (count);
	[self writeBuffer: "lines"];
	
	return self;
}


/*
================
=
= writeThings
=
================
*/

- writeThings
{
	int		i;
	int		line, side;
	worldthing_t	*wthing;
	mapthing_t	*thing;
	int		count;
	
	count = 0;
//
// write out the things
//
	buf_p = buffer+4;
	
	for (i= 0 ; i<numthings ; i++)
	{
		wthing = &things[i];
		if (wthing->selected == -1)
			continue;
			
		count ++;
		
		thing = (mapthing_t *)buf_p;
		buf_p += sizeof(mapthing_t);
		
		// find the line nearest the thing to get it's sector number
		
		line = LineByPoint (&wthing->origin, &side);
		if (line == -1)
			[editworld_i selectThing: i];
		else
		{
			if (side== 1 && !(lines[line].flags & ML_TWOSIDED) )
				[editworld_i selectThing: i];
			else
				thing->sector = ShortSwap (lines[line].side[side].sector);
		}
		
		thing->origin.x = ShortSwap( (int)wthing->origin.x );
		thing->origin.y = ShortSwap( (int)wthing->origin.y );

		thing->angle = ShortSwap (wthing->angle);
		thing->type = ShortSwap (wthing->type);
		thing->options = ShortSwap (wthing->options);
	}

	
	*(int *)buffer = LongSwap (count);
	[self writeBuffer: "things"];
	
	return self;
}


/*
================
=
= writeSectors
=
================
*/

- writeSectors
{
	int			i,j;
	int			*linenum;
	int			count, lcount;
	int			*list_p;
	worldsector_t	*wsector;
	mapsector_t	*msector;

	count = [sectors count];
		
	*(int *)buffer = LongSwap (count);
	list_p = (int *)(buffer + 4);
	buf_p = (byte *)(list_p+count);

	for (i=0 ; i<count ; i++)		
	{
		*list_p++ = LongSwap (buf_p-buffer);
		wsector = [sectors elementAt: i];
		lcount = [wsector->lines count];
		
		msector = (mapsector_t *)buf_p;
		buf_p += sizeof(mapsector_t) + (lcount-1)*sizeof(short);
		
		msector->floorheight = ShortSwap (wsector->s.floorheight);
		msector->ceilingheight = ShortSwap (wsector->s.ceilingheight);
		msector->lightlevel = ShortSwap (wsector->s.lightlevel);
		msector->special = ShortSwap (wsector->s.special);
		msector->tag = ShortSwap (wsector->s.tag);
		msector->floortexture = 
			ShortSwap (lumptoflatnum[[wadfile_i lumpNamed: wsector->s.floorflat]] );
		msector->ceilingtexture = 
			ShortSwap (lumptoflatnum[[wadfile_i lumpNamed: wsector->s.ceilingflat]] );
		msector->linecount = ShortSwap (lcount);
		
		for (j=0 ; j<lcount ; j++)
		{
			linenum = [wsector->lines elementAt:j];
			msector->lines[j] = ShortSwap(linecrunch[*linenum]);
		}
	}
		
	[self writeBuffer: "sectors"];

			
	return self;
}


/*
================
=
= saveDoomMap
=
= Writes out lumps for the doom executable
=
================
*/
#define	MAXMAPSIZE	100000

- saveDoomMap
{
	char		path[1025];

	[editworld_i deselectAll];
	
	if (![blockworld_i connectSectors])
		return self;		// don't continue if there were sector errors
	
//
// have the project save out the latest textures
//
//	[doomproject_i saveDoomLumps];
	
//
// make a wad file for everything in this map
//
	strcpy (path, [doomproject_i wadfile]);
	StripFilename (path);
	strcat (path,"/");
	ExtractFileName ( pathname, path+strlen (path));
	StripExtension (path);
	strcat (path,".wad");
	
	mapwad_i = [[Wadfile alloc] initNew: path];
	
//
// write a label at the start
//
	ExtractFileName (pathname, path);
	StripExtension (path);
	[mapwad_i addName: path data: path size: 0];
		
	worldsize = 0;
	buffer = buf_p = malloc (MAXMAPSIZE);

	[self writeFlatNames];		// builds lumptoflatnum[]
	[self writePoints];			// builds pointcrunch[]
	[self writeLines];			// builds linecrunch[]
	[self writeSectors];
	[self writeThings];

	[mapwad_i writeDirectory];
	[mapwad_i free];
	
	free (buffer);
	printf ("Save completed (%i bytes)\n", worldsize);
	
	[editworld_i updateWindows];
	
	return self;
}

@end

