#import "DoomProject.h"
#import "TextureEdit.h"
#import "TexturePalette.h"
#import "SectorEditor.h"
#import "SectorPalette.h"
#import "EditWorld.h"
#import "Wadfile.h"
#import "R_mapdef.h"

id	doomproject_i;
id	wadfile_i;

int	numtextures, numends;
worldtexture_t		*textures;
worldends_t		*ends;

#define BASELISTSIZE	32


@implementation DoomProject


/*
=============================================================================

						PROJECT METHODS

=============================================================================
*/


- init
{
	loaded = NO;
	doomproject_i = self;
	window_i = NULL;
	numends = numtextures = 0;
	endssize = texturessize = BASELISTSIZE;
	textures = malloc (texturessize*sizeof(worldtexture_t));
	ends = malloc (endssize*sizeof(worldends_t));
	return self;
}

- (BOOL)loaded
{
	return loaded;
}

- (char *)wadfile
{
	return wadfile;
}


- (char const *)directory
{
	return projectdirectory;
}


/*
===============
=
= loadPV1File:
=
===============
*/

- (BOOL)loadPV1File: (FILE *)stream
{
	int		i;
	
	if (fscanf (stream, "\nwadfile: %s\n",wadfile) != 1)
		return NO;
		
	if (fscanf(stream,"\nnummaps: %d\n", &nummaps) != 1)
		return NO;
		
	for (i=0 ; i<nummaps ; i++)
		if (fscanf(stream,"%s\n", mapnames[i]) != 1)
			return NO;


	return YES;
}

/*
===============
=
= savePV1File:
=
===============
*/

- savePV1File: (FILE *)stream
{
	int		i;
	
	fprintf (stream, "\nwadfile: %s\n",wadfile);
	fprintf (stream,"\nnummaps: %d\n", nummaps);
		
	for (i=0 ; i<nummaps ; i++)
		fprintf (stream,"%s\n", mapnames[i]);

	return self;
}


/*
===============
=
= menuTarget
=
===============
*/

- menuTarget: sender
{
	if (!loaded)
	{
		NXRunAlertPanel ("Error","No project loaded",NULL,NULL,NULL);
		return nil;
	}
	
	if (!window_i)
	{
		[NXApp 
			loadNibSection:	"Project.nib"
			owner:			self
			withNames:		NO
		];
		
	}

	[self updatePanel];
	[window_i orderFront:self];

	return self;
}


/*
===============
=
= openProject
=
===============
*/

- openProject: sender
{
	id			openpanel;
	static char	*suffixlist[] = {"dpr", 0};
	char		const	*filename;

	if (loaded)
	{
		NXRunAlertPanel ("Error","A project is allready open",NULL,NULL,NULL);
		return nil;
	}
	
	openpanel = [OpenPanel new];
	if (![openpanel runModalForTypes:suffixlist] )
		return NULL;

	filename = [openpanel filename];
	
	if (![self loadProject: filename])
		return nil;

	return self;
}

/*
===============
=
= newProject
=
===============
*/

- newProject: sender
{
	id			panel;
	char		const *filename;
	static char *fileTypes[] = { "wad",NULL};

	if (loaded)
	{
		NXRunAlertPanel ("Error","A project is allready open",NULL,NULL,NULL);
		return nil;
	}
	
//
// get directory for files
//	
	panel = [OpenPanel new];
	[panel setTitle: "Project directory"];
	[panel chooseDirectories:YES];
	if (! [panel runModal] )
		return self;
		
	filename = [panel filename];
	if (!filename || !*filename)
		return self;
		
	strcpy (projectdirectory, filename);
	
//
// get wadfile
//
	[panel setTitle: "Wadfile"];
	[panel chooseDirectories:NO];
	if (! [panel runModalForTypes: fileTypes] )
		return self;
		
	filename = [panel filename];
	if (!filename || !*filename)
		return self;
		
	strcpy (wadfile, filename);
		
//
// create default data
//
	nummaps = 0;
	numtextures = 0;
	numends = 0;

//
// load in and init all the WAD patches
//
	loaded = YES;
	
	[textureEdit_i	initPatches];
	[self menuTarget: self];		// bring the panel to front

	return self;
}


/*
===============
=
= saveProject
=
===============
*/

- saveProject: sender
{
	FILE		*stream;
	char		filename[1024];

	if (!loaded)
		return nil;
		
	strcpy (filename, projectdirectory);
	strcat (filename ,"/project.dpr");
	stream = fopen (filename,"w");
	fprintf (stream, "Doom Project version 1\n");
	[self savePV1File: stream];
	fclose (stream);
	projectdirty = NO;

	[self updateTextures];
	[self updateEnds];
	
	return self;
}


/*
===============
=
= reloadProject
=
===============
*/

- reloadProject: sender
{
	if (!loaded)
		return nil;
		
	[self updateTextures];
	[self updateEnds];
	
	return self;
}


/*
=============================================================================

						PRIVATE METHODS
						
=============================================================================
*/

/*
===============
=
= updatePanel
=
===============
*/

- updatePanel
{
	[projectpath_i setStringValue: projectdirectory];
	[wadpath_i setStringValue: wadfile];
	[maps_i reloadColumn: 0];	
	return self;
}




/*
===============
=
= loadProject:
=
= Called either by openProject: or when a map is auto launched
=
===============
*/

- loadProject: (char const *)path
{
	FILE		*stream;
	char		projpath[1024];
	int		version, ret;
	
	strcpy (projectdirectory, path);
	StripFilename (projectdirectory);
	
	strcpy (projpath, projectdirectory);
	strcat (projpath, "/project.dpr");
	
	stream = fopen (projpath,"r");
	if (!stream)
	{
		NXRunAlertPanel ("Error","Couldn't open %s",NULL,NULL,NULL, projpath);
		return nil;	
	}
	version = -1;
	fscanf (stream, "Doom Project version %d\n", &version);
	if (version == 1)
		ret = [self loadPV1File: stream];
	else
	{
		fclose (stream);
		NXRunAlertPanel ("Error","Unknown file version for project %s",NULL,NULL,NULL, projpath);
		return nil;	
	}

	if (!ret)
	{
		fclose (stream);
		NXRunAlertPanel ("Error","Couldn't parse project file %s",NULL,NULL,NULL, projpath);
		return nil;	
	}
	
	fclose (stream);
	
	projectdirty = NO;
	texturesdirty = NO;
	endsdirty = NO;
	loaded = YES;
	wadfile_i = [[Wadfile alloc] initFromFile: wadfile];
	if (!wadfile_i)
	{
		NXRunAlertPanel ("Error","Couldn't open wadfile %s",NULL,NULL,NULL, wadfile);
		return nil;	
	}
	
	[self updateTextures];
	[self updateEnds];
	[self menuTarget: self];		// bring the panel to front
	[textureEdit_i	initPatches];
	[texturePalette_i	initTextures];
	[sectorEdit_i	loadFlats];
	[sectorPalette_i	buildSectors];
		
	[wadfile_i close];
	
	return self;
}


/*
=============================================================================

						MAP METHODS
						
=============================================================================
*/


/*
===============
=
= removeMap:
=
===============
*/

- removeMap:sender
{

	return self;
}


/*
===============
=
= browser:fillMatrix:inColumn:
=
===============
*/

- (int)browser:sender  fillMatrix:matrix  inColumn:(int)column
{
	int	i;
	id	cell;

	if (column != 0)
		return 0;
		
	for (i=0 ; i<nummaps ; i++)
	{
		[matrix addRow];
		cell = [matrix cellAt: i : 0];
		[cell setStringValue: mapnames[i]];
		[cell setLeaf: YES];
		[cell setLoaded: YES];
		[cell setEnabled: YES];
	}
	
	return nummaps;
}

/*
=====================
=
= newMap
=
= A world name was typed in the new field
=
=====================
*/

- newMap: sender
{
	FILE		*stream;
	char		pathname[1024];
	char		const	*title;
	int		len, i;

//
// get filename for map
//	
	title = [sender stringValue];
	len = strlen (title);
	if (len < 1 || len > 8)
	{
		NXRunAlertPanel ("Error","Map names must be 1 to 8 characters",NULL, NULL, NULL);
		return nil;
	}
	
	for (i=0 ; i<nummaps ; i++)
		if (!strcmp(title, mapnames[i]))
		{
			NXRunAlertPanel ("Error","Map name in use",NULL, NULL, NULL);
			return nil;
		}
		
//
// write an empty file
//
	strcpy (pathname, projectdirectory);
	strcat (pathname, "/");
	strcat (pathname,title);
	strcat (pathname,".dwd");
	stream = fopen (pathname,"w");
	if (!stream)
	{
		NXRunAlertPanel ("Error","Could not open %s",NULL, NULL, NULL, pathname);
		return nil;	
	}
	fprintf (stream, "WorldServer version 0\n");
	fclose (stream);

//
// add the map and update the browser
//
	strcpy (mapnames[nummaps], title);
	nummaps++;
	
	[self updatePanel];
	[self saveProject: self];
	
	return self;
}

/*
=====================
=
= openMap:
=
= A world name was clicked on in the browser
=
=====================
*/

- openMap:sender
{
	id			cell;
	const char	*title;
	char			fullpath[1024];

	if ([editworld_i loaded])
		[editworld_i closeWorld];
	
	cell = [sender selectedCell];
	title = [cell stringValue];
	
	strcpy (fullpath, projectdirectory);
	strcat (fullpath,"/");
	strcat (fullpath,title);
	strcat (fullpath,".dwd");
	
	[editworld_i loadWorldFile: fullpath];
	return self;
}


/*
=============================================================================

						TEXTURE / ENDS METHODS
						
=============================================================================
*/

/*
=================
=
= read/writeTexture
=
=================
*/

- (BOOL)readTexture: (worldtexture_t *)tex from: (FILE *)file
{
	int	i;
	worldpatch_t	*patch;
	
	memset (tex, 0, sizeof(*tex));

	if (fscanf (file,"%s %d, %d, %d\n", tex->name, &tex->width, &tex->height
	, &tex->patchcount) != 4)
		return NO;
		
	for (i=0 ; i<tex->patchcount ; i++)
	{
		patch = &tex->patches[i];
		if (fscanf (file,"   (%d, %d : %s ) %d, %d\n",&patch->originx, &patch->originy,
			patch->patchname, &patch->stepdir, &patch->colormap) != 5)
			return NO;
	}

	return YES;
}

- writeTexture: (worldtexture_t *)tex to: (FILE *)file
{
	int	i;
	worldpatch_t	*patch;
	
	fprintf (file,"%s %d, %d, %d\n", tex->name, tex->width, tex->height, tex->patchcount);
	for (i=0 ; i<tex->patchcount ; i++)
	{
		patch = &tex->patches[i];
		fprintf (file,"   (%d, %d : %s ) %d, %d\n",patch->originx, patch->originy,
			patch->patchname, patch->stepdir, patch->colormap);
	}

	return self;
}


/*
=================
=
= read/writeEnds
=
=================
*/

- (BOOL)readEnds: (worldends_t *)end from: (FILE *)file
{	
	memset (end, 0, sizeof(*end));

	if (fscanf (file,"%s %d : %s %d : %s %d %d\n", end->name, &end->s.floorheight,
	end->s.floorflat, &end->s.ceilingheight, end->s.ceilingflat
	, &end->s.lightlevel, &end->s.special) != 7)
		return NO;

	return YES;
}

- writeEnds: (worldends_t *)end to: (FILE *)file
{	
	fprintf (file,"%s %d : %s %d : %s %d %d\n", end->name, end->s.floorheight,
	end->s.floorflat, end->s.ceilingheight, end->s.ceilingflat
	, end->s.lightlevel, end->s.special);
	
	return self;
}


/*
================
=
= texture/endsNamed:
=
= Returns the number of the data with the given name, -1 if no texture, -2 if  name not found
=
================
*/

- (int)textureNamed: (char const *)name
{
	int	i;
	
	if (!strlen(name) || !strcmp (name, "-") )
		return -1;		// no texture
		
	for (i=0 ; i<numtextures ; i++)
		if (!strcasecmp(textures[i].name, name) )
			return i;
	return -2;	
}

- (int)endsNamed: (char const *)name
{
	int	i;
	
	for (i=0 ; i<numends ; i++)
		if (!strcasecmp(ends[i].name, name) )
			return i;
	return -1;
}

/*
===============
=
= updateTextures
=
= Opens textures.dpr from the project directory exclusively, then reads in any new
= changes, then writes everything back out
=
===============
*/

- updateTextures
{
	FILE		*stream;
	int		handle;
	char		filename[1024];
	int		count,i, num;
	worldtexture_t		tex;
	
	strcpy (filename, projectdirectory);
	strcat (filename ,"/textures.dpr");

	handle = open (filename, O_CREAT | O_RDWR, 0666);
	if (handle == -1)
	{
		NXRunAlertPanel ("Error","Couldn't open %s",NULL,NULL,NULL, filename);
		return self;
	}		

	flock (handle, LOCK_EX);
	
	stream = fdopen (handle,"r+");
	if (!stream)
	{
		fclose (stream);
		NXRunAlertPanel ("Error","Could not stream to %s",NULL,NULL,NULL, filename);
		return self;
	}
	
//
// read textures out of the file
//
	if (fscanf (stream, "numtextures: %d\n", &count) == 1)
	{
	
		for (i=0 ; i<count ; i++)
		{
			if (![self readTexture: &tex from: stream])
			{
				fclose (stream);
				NXRunAlertPanel ("Error","Could not parse %s",NULL,NULL,NULL, filename);
				return self;
			}
		//
		// if the name is present but not modified, update it to the current value
		// if the name is present and modified, don't update it
		// if the name is not present, add it
		//
			num = [self textureNamed:tex.name];
			if (num == -2)
				[self newTexture: &tex];
			else
			{
				if (!textures[num].dirty)
					[self changeTexture: num to: &tex];
			}
		}
	}
	
//
// go back to the beginning and write all the textures out
//
	if (texturesdirty)
	{
printf ("updating texture file\n");
		texturesdirty = NO;
		fseek (stream, 0, SEEK_SET);
		fprintf (stream, "numtextures: %d\n",numtextures);
		for (i=0 ; i<numtextures ; i++)
		{
			textures[i].dirty = NO;
			[self writeTexture: &textures[i] to: stream];
		}
	}

	flock (handle, LOCK_UN);
	fclose (stream);

	return self;
}

/*
===============
=
= updateEnds
=
= Opens ends.dpr from the project directory exclusively, then reads in any new
= changes, then writes everything back out
=
===============
*/

- updateEnds
{
	FILE		*stream;
	int		handle;
	char		filename[1024];
	int		count, i, num;
	worldends_t		end;
	
	strcpy (filename, projectdirectory);
	strcat (filename ,"/ends.dpr");

	handle = open (filename, O_CREAT | O_RDWR, 0666);
	if (handle == -1)
	{
		NXRunAlertPanel ("Error","Couldn't open %s",NULL,NULL,NULL, filename);
		return self;
	}		

	flock (handle, LOCK_EX);
	stream = fdopen (handle,"r+");
	if (!stream)
	{
		fclose (stream);
		NXRunAlertPanel ("Error","Could not stream to %s",NULL,NULL,NULL, filename);
		return self;
	}
	
//
// read textures out of the file
//
	if (fscanf (stream, "numends: %d\n", &count) == 1)
	{
		for (i=0 ; i<count ; i++)
		{
			if (![self readEnds: &end from: stream])
			{
				fclose (stream);
				NXRunAlertPanel ("Error","Could not parse %s",NULL,NULL,NULL, filename);
				return self;
			}
		//
		// if the name is present but not modified, update it to the current value
		// if the name is present and modified, don't update it
		// if the name is not present, add it
		//
			num = [self endsNamed:end.name];
			if (num == -1)
				[self newEnds: &end];
			else
			{
				if (!ends[num].dirty)
					[self changeEnds: num to: &end];
			}
		}
	}
	
//
// go back to the beginning and write all the ends out
//
	if (endsdirty)
	{
printf ("updating ends file\n");
		endsdirty = NO;
		fseek (stream, 0, SEEK_SET);
		fprintf (stream, "numends: %d\n",numends);
		for (i=0 ; i<numends ; i++)
		{
			textures[i].dirty = NO;
			[self writeEnds: &ends[i] to: stream];
		}
	}
	flock (handle, LOCK_UN);
	fclose (stream);

	return self;
}


/*
===============
=
= newTexture
=
===============
*/

- (int)newTexture: (worldtexture_t *)tex
{
	if (numtextures == texturessize)
	{
		texturessize += 32;		// add space to array
		textures = realloc (textures, texturessize*sizeof(worldtexture_t));
	}
	numtextures++;
	[self changeTexture: numtextures-1 to: tex];
	return numtextures-1;
}


/*
===============
=
= changeTexture
=
===============
*/

- changeTexture: (int)num to: (worldtexture_t *)tex
{
	texturesdirty = YES;
	textures[num] = *tex;
	textures[num].dirty = YES;
	return self;
}


/*
===============
=
= newEnds
=
===============
*/

- (int)newEnds: (worldends_t *)en
{
	if (numends == endssize)
	{
		endssize += 32;		// add space to array
		ends = realloc (ends, endssize*sizeof(worldends_t));
	}
	numends++;
	[self changeEnds: numends-1 to:en];
	return numends-1;
}


/*
===============
=
= changeEnds
=
===============
*/

- changeEnds: (int)num to: (worldends_t *)en
{
	endsdirty = YES;
	ends[num] = *en;
	ends[num].dirty = YES;
	return self;
}


/*
=============================================================================

						DOOM METHODS
						
=============================================================================
*/

static	int		lumptopatchnum[4096];
static	byte		*buffer, *buf_p;

- (byte *)getBuffer
{
	buffer = malloc (100000);
	return buffer;
}

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
	FILE		*stream;
	char		directory[1024];
	
	strcpy (directory, wadfile);
	StripFilename (directory);
	chdir (directory);
	
	size = buf_p - buffer;
	stream = fopen (filename,"w");
	fwrite (buffer, size, 1, stream);
	fclose (stream);
	printf ("%s:  %i bytes\n", filename, size);

	free (buffer);
			
	return self;
}


/*
================
=
= writePatchNames
=
================
*/

- writePatchNames
{
	int	count, i,j;
	worldtexture_t	*tex;
	int	lump;
	
	buffer = [self getBuffer];
//
// write out names of wall patches used
//
	count = 0;
	buf_p = buffer + 4;
	memset (lumptopatchnum, -1, sizeof(lumptopatchnum));
	
	for (i= 0 ; i<numtextures ; i++)
	{
		tex = &textures[i];
		for (j=0 ; j<tex->patchcount ; j++)
		{
			lump = [wadfile_i lumpNamed: tex->patches[j].patchname];
			if (lumptopatchnum[lump] == -1)
			{
				memcpy (buf_p, tex->patches[j].patchname,8);
				buf_p += 8;
				lumptopatchnum[lump] = count;
				count++;
			}
		}
	}
		
	*(int *)buffer = LongSwap (count);
	[self writeBuffer: "pnames.lmp"];

	return self;
}



/*
===============
=
= writeDoomTextures
=
= Writes out a textures.lmp file with the doom version of all the textures
=
===============
*/

- writeDoomTextures
{
	mappatch_t	*patch;
	maptexture_t	*tex;
	worldtexture_t	*wtex;
	worldpatch_t	*wpatch;
	int			*list_p;
	int			i,j;

	[self getBuffer];

//
// leave space for an index table
//
	*(int *)buffer = LongSwap (numtextures);
	list_p = (int *)(buffer + 4);
	buf_p = buffer + (numtextures+1)*4;
	
//
// write out textures used
//	
	for (i=0 ; i<numtextures ; i++)
	{
		wtex = &textures[i];

		*list_p++ = LongSwap (buf_p-buffer);
		tex = (maptexture_t *)buf_p;
		buf_p += sizeof(*tex) - sizeof(tex->patches);
		
		tex->masked = false;
		tex->width = ShortSwap (wtex->width);
		tex->height = ShortSwap (wtex->height);
		tex->collumndirectory = NULL;
		tex->patchcount = ShortSwap(wtex->patchcount);
		for (j=0 ; j<wtex->patchcount ; j++)
		{
			wpatch = &wtex->patches[j];
			patch = (mappatch_t *)buf_p;
			buf_p += sizeof(mappatch_t);
			
			patch->originx = ShortSwap(wpatch->originx);
			patch->originy = ShortSwap(wpatch->originy);
			patch->patch = ShortSwap( 
				lumptopatchnum [ [wadfile_i lumpNamed: wpatch->patchname]  ]  );
			patch->stepdir = ShortSwap(wpatch->stepdir);
			patch->colormap = ShortSwap(wpatch->colormap);
		}	
	}
	
	
//
// write it out to disk
//
	[self writeBuffer: "textures.lmp"];

	return self;
}

/*
===============
=
= saveDoomLumps
=
= Writes out textures.lmp file with the doom version of all the textures
=
===============
*/

- saveDoomLumps
{
	chdir (projectdirectory);
	[self writePatchNames];
	[self writeDoomTextures];
	
	return self;
}

@end

/*
================
=
= IO_Error
=
================
*/

void IO_Error (char *error, ...)
{
	va_list	argptr;
	char		string[1024];

	va_start (argptr,error);
	vsprintf (string,error,argptr);
	va_end (argptr);
	NXRunAlertPanel ("Error",string,NULL,NULL,NULL);
	[NXApp terminate: NULL];
}

