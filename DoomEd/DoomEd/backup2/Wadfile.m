#import "Wadfile.h"
#import "idfunctions.h"
#import <ctype.h>

typedef struct
{
	char		identification[4];		// should be IWAD
	int		numlumps;
	int		infotableofs;
} wadinfo_t;


typedef struct
{
	int		filepos;
	int		size;
	char		name[8];
} lumpinfo_t;


@implementation Wadfile

//=============================================================================

/*
============
=
= initFromFile:
=
============
*/

- initFromFile: (char const *)path
{
	wadinfo_t	wad;
	lumpinfo_t	*lumps;
	int			i;
	
	pathname = malloc(strlen(path)+1);
	strcpy (pathname, path);
	dirty = NO;
	handle = open (pathname, O_RDWR, 0666);
	if (handle== -1)
	{
		[self free];
		return nil;
	}
//
// read in the header
//
	read (handle, &wad, sizeof(wad));
	if (strncmp(wad.identification,"IWAD",4))
	{
		close (handle);
		[self free];
		return nil;
	}
	wad.numlumps = LongSwap (wad.numlumps);
	wad.infotableofs = LongSwap (wad.infotableofs);
	
//
// read in the lumpinfo
//
	lseek (handle, wad.infotableofs, L_SET);
	info = [[Storage alloc] initCount: wad.numlumps elementSize: sizeof(lumpinfo_t) description: ""];
	lumps = [info elementAt: 0];
	
	read (handle, lumps, wad.numlumps*sizeof(lumpinfo_t));
	for (i=0 ; i<wad.numlumps ; i++, lumps++)
	{
		lumps->filepos = LongSwap (lumps->filepos);
		lumps->size = LongSwap (lumps->size);
	}
	
	return self;
}


/*
============
=
= initNew:
=
============
*/

- initNew: (char const *)path
{
	wadinfo_t	wad;

	pathname = malloc(strlen(path)+1);
	strcpy (pathname, path);
	info = [[Storage alloc] initCount: 0 elementSize: sizeof(lumpinfo_t) description: ""];
	dirty = YES;
	handle = open (pathname, O_CREAT | O_TRUNC | O_RDWR, 0666);
	if (handle== -1)
		return nil;
// leave space for wad header
	write (handle, &wad, sizeof(wad));
	
	return self;
}

-close
{
	close (handle);
	return self;
}

-free
{
	close (handle);
	[info free];
	free (pathname);
	return [super free];
}

//=============================================================================

- (int)numLumps
{
	return [info count];
}

- (int)lumpsize: (int)lump
{
	lumpinfo_t	*inf;
	inf = [info elementAt: lump];
	return inf->size;
}

- (int)lumpstart: (int)lump
{
	lumpinfo_t	*inf;
	inf = [info elementAt: lump];
	return inf->filepos;
}

- (char const *)lumpname: (int)lump
{
	lumpinfo_t	*inf;
	inf = [info elementAt: lump];
	return inf->name;
}

/*
================
=
= lumpNamed:
=
================
*/

- (int)lumpNamed: (char const *)name
{
	lumpinfo_t	*inf;
	int			i, count;
	char			name8[9];
	int			v1,v2;

// make the name into two integers for easy compares

	memset(name8,0,9);
	if (strlen(name) < 9)
		strncpy (name8,name,9);
	for (i=0 ; i<9 ; i++)
		name8[i] = toupper(name8[i]);	// case insensitive

	v1 = *(int *)name8;
	v2 = *(int *)&name8[4];


// scan backwards so patch lump files take precedence

	count = [info count];
	for (i=count-1 ; i>=0 ; i--)
	{
		inf = [info elementAt: i];
		if ( *(int *)inf->name == v1 && *(int *)&inf->name[4] == v2)
			return i;
	}
	return  -1;
}

/*
================
=
= loadLump:
=
================
*/

- (void *)loadLump: (int)lump
{
	lumpinfo_t	*inf;
	byte			*buf;
	
	inf = [info elementAt: lump];
	buf = malloc (inf->size);
	
	lseek (handle, inf->filepos, L_SET);
	read (handle, buf, inf->size);
	
	return buf;
}

- (void *)loadLumpNamed: (char const *)name
{
	return [self loadLump:[self lumpNamed: name]];
}

//============================================================================

/*
================
=
= addName:data:size:
=
================
*/

- addName: (char const *)name data: (void *)data size: (int)size
{
	int		i;
	lumpinfo_t	new;
	
	dirty = YES;
	memset (new.name,0,sizeof(new.name));
	strncpy (new.name, name, 8);
	for (i=0 ; i<8 ; i++)
		new.name[i] = toupper(new.name[i]);
	new.filepos = lseek(handle,0, L_XTND);
	new.size = size;
	[info addElement: &new];
	
	write (handle, data, size);
	
	return self;
}


/*
================
=
= writeDirectory:
=
	char		identification[4];		// should be IWAD
	int		numlumps;
	int		infotableofs;
================
*/

- writeDirectory
{
	wadinfo_t	wad;
	int			i,count;
	lumpinfo_t	*inf;
	
//
// write the directory
//
	count = [info count];
	inf = [info elementAt:0];
	for (i=0 ; i<count ; i++)
	{
		inf[i].filepos = LongSwap (inf[i].filepos);
		inf[i].size = LongSwap (inf[i].size);
	}
	wad.infotableofs = LongSwap (lseek(handle,0, L_XTND));
	write (handle, inf, count*sizeof(lumpinfo_t));
	for (i=0 ; i<count ; i++)
	{
		inf[i].filepos = LongSwap (inf[i].filepos);
		inf[i].size = LongSwap (inf[i].size);
	}
	
//
// write the header
//
	strncpy (wad.identification, "IWAD",4);
	wad.numlumps = LongSwap ([info count]);
	lseek (handle, 0, L_SET);
	write (handle, &wad, sizeof(wad));
	
	return self;
}

@end

