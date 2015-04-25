
@interface WadCache: Object
{
	char	wadpath[MAXPATH];
	char	cachepath[MAXPATH];
	char	cachedirpath[MAXPATH];
	
	int		mappedfd;
	char	*imageblock;
	int		imageblocksize;
	
	int		numflats, numflats1;
	int		numpatches, numpatches1;
	
	id		datastore_i;
}

- initFromWadfile:(char const *)wadfile cacheFile:(char const *)cachefile
- free;

- (int)numFlats;
- (int)numFlats1;
- flatNumForName: (char const *)name;
- (char const *)flatNameForNum: (int)num;
- flatImageForNum: (int)num;
- flatImageForNamed: (char const *)name;

- (int)numPatches;
- (int)numPatches1;
- patchNumForName: (char const *)name;
- (char const *)patchNameForNum: (int)num;
- patchImageForNum: (int)num;
- patchImageForNamed: (char const *)name;

@end

typedef struct
{
	char	name[12];
	int		width, height;
	id		image_i;
} imagedata_t;


	
/*
=========================
=
= initFromWadfile:cacheFile:
=
=========================
*/

- initFromWadfile:(char const *)wadfile cacheFile:(char const *)cachefile
{
	struct	stat	buf1, buf2;
	int				ret1, ret2;
	
	
	strcpy (wadpath, wadfile);
	strcpy (cachepath, cachefile);
	strcpy (cachedirpath, cachefile);
	strcat (cachedirpath, "d");
	
//
// get timestamps of file
//
	ret1 = stat (wadpath, &buf1);
	if (ret1 < 0)
	{
		perror ("initFromWadfile: stat ");
		[self free];
		return nil;
	}
	ret2 = stat (cachepath, &buf1);
		
	if (ret2<0 || buf1.st_ctime > buf2.st_ctime)
		[self createImageCache];
	else
		[self loadImageCache];

	[self makeImagesFromBlock];
	
	return self;
}


/*
===================
=
= free
=
===================
*/

- free
{
	int		ret;

//
// free images
//

	
//
// free imageblock
//
	if (mappedfd)
	{
		close (mappedfd);
		ret = vm_deallocate (task_self(), imageblock, imageblocksize);
		if (ret != KERN_SUCCESS)
			mach_error ("free: vm_deallocate ");
	}		
	else
		free (imageblock);
		
}


- flatNumForName: (char const *)name
{
}

- (char const *)flatNameForNum: (int)num
{
}

- flatImageNum: (int)num
{
}

- flatImageNamed: (char const *)name
{
}


- patchNumForName: (char const *)name
{
}

- patchImageNum: (int)num
{
}

- patchImageNamed: (char const *)name
{
}

//=============================================================================


/*
===================
=
= loadImageCache
=
===================
*/

- loadImageCache
{
	int				ret;
	struct	stat	buf;
	
	mappedfd = open (cachepath, O_RDONLY);
	if (mappedfd < 0)
	{
		perror (loadImageCache: open ");
		return nil;
	}
	
	ret = fstat (mappedfd, &buf);
	if (ret < 0)
	{
		close (mappedfd);
		perror (loadImageCache: fstat ");
		return nil;
	}
	imageblocksize = buf.size;
	
	ret = map_fd(mappedfd, 0, &imageblock, TRUE, imageblocksize);
	if (ret != KERN_SUCCESS)
	{
		close (mappedfd);
		mach_error ("loadImageCache: map_fd ");
		return nil;
	}
	return self;
}



/*
===================
=
= patchToImage
=
===================
*/

id	patchToImage(patch_t *patchData, unsigned short *shortpal,NXSize *size)
{
	byte			*dest_p;
	NXImageRep *image_i;
	id			fastImage_i;
	int			width,height,count,topdelta;
	byte const	*data;
	int			i,index;

	width = patchData->width;
	height = patchData->height;
	size->width = width;
	size->height = height;
	//
	// make an NXimage to hold the data
	//
	image_i = [[NXBitmapImageRep alloc]
		initData:			NULL 
		pixelsWide:		width 
		pixelsHigh:		height
		bitsPerSample:	4
		samplesPerPixel:	4 
		hasAlpha:		YES
		isPlanar:			NO 
		colorSpace:		NX_RGBColorSpace 
		bytesPerRow:		width*2
		bitsPerPixel: 		16
	];

	if (!image_i)
		return nil;
				
	//
	// translate the picture
	//
	dest_p = [(NXBitmapImageRep *)image_i data];
	memset(dest_p,0,width * height * 2);
	
	for (i = 0;i < width; i++)
	{
		data = (byte *)patchData + ShortSwap(patchData->collumnofs[i]);
		while (1)
		{
			topdelta = *data++;
			if (topdelta == (byte)-1)
				break;
			count = *data++;
			index = (topdelta*width+i)*2;
			while (count--)
			{
				*((unsigned short *)(dest_p + index)) = shortpal[*data++];
				index += width * 2;
			}
		}
	}

	fastImage_i = [[NXImage	alloc]
							init];
	[fastImage_i	useRepresentation:(NXImageRep *)image_i];	
	return fastImage_i;
}




/*
===================
=
= createImageCache
=
===================
*/

- createImageCache
{
	short	*block_p;
	byte	*lbmpal;
	short	shortpal[256];
	byte	*palimage;
	patch_t	**patchlumps, *plump;
	int		handle;
	
//
// open wadfile
//
	printf ("creating cachefile...\n");
	
	open wadfile

	flat1start = [wadfile_i lumpNamed:"F1_START"];
	flat1end = [wadfile_i lumpNamed:"F1_END"];
	patch1start = [wadfile_i lumpNamed:"P1_START"];
	patch1end = [wadfile_i lumpNamed:"P1_END"];

	numflats = 
	numpatches =
	
//
// count up space required to hold flat and patch images
//
	patchlumps = alloca(numpatches*4);
	imageblocksize = numflats*8192;
	for (i=0 ; i<numpatches ; i++)
	{
		patchlumps[i] = [wadfile_i ];
		pd = 
		imageblocksize += pd->width*2*pd->height;
	}
	
	imageblock = block_p = malloc (imageblocksize);
	
//
// load palette and convert images
//
	lbmpal = [wadfile_i	loadLumpNamed:"playpal"];
	if (lbmpal == NULL)
		IO_Error ("Need to have 'playpal' palette in .WAD file!");
	LBMpaletteTo16 (lbmpal, shortpal);
	free (lbmpal);
	
//
// convert flats
//
	for (i=0 ; i<numflats ; i++)
	{
		palimage =
		for (x=0 ; x<4096 ; x++)
			*block_p++ = shortpal[palimage[x]];
		free (palimage);
	}

	[wadfile_i free];		// all done with wadfile

//
// convert patches
//
	for (i=0 ; i<numpatches ; i++)
	{
		plump = patchlumps[i];
		block_p += [self convertPatch:plump at:block_p withPal:shortpal];
		free (plump);
	}

//
// write directory
//
	dir = fopen (cachedirpath, "w");
	fprintf (dir,"numflats: %i numpatches: %i\n", numflats, numpatches);
	pd = [patchstore_i elementAt:0];
	for (i=0 ; i<numpatches ; i++)
	{
		fprintf (dir, "%i %i\n", pd->width, pd->height);
		pd++;
	}
	fclose (dir);
	

//
// write cache file
//
	printf ("writing cachefile...\n");
	handle = open (cachepath, O_RDWR | O_CREAT | O_TRUNC, 0666);
	i = write (handle, imageblock, imageblocksize);
	if (i != imageblocksize)
		printf ("ERROR: only wrote %i of %i bytes of cachefile %s\n"
		, i, imageblocksize, cachepath);
	close (handle);
	
}


/*
===================
=
= makeImagesFromBlock
=
===================
*/

- makeImagesFromBlock
{
	int			i;
	char		*block_p;
	flatdat_t	*fd;
	patchdat_t	*pd;
	id			image_i;
	
	
	block_p = datablock;
	
	
	fd = [flatstore_i elementAt: 0];

	for (i=0 ; i<numflats ; i++)
	{
		image_i = [[NXBitmapImageRep alloc]
			initData:			block_p 
			pixelsWide:			64 
			pixelsHigh:			64
			bitsPerSample:		4
			samplesPerPixel:	3 
			hasAlpha:			NO
			isPlanar:			NO 
			colorSpace:			NX_RGBColorSpace 
			bytesPerRow:		128
			bitsPerPixel: 		16
		];
		
		block_p += 128*64;
		fd->image = image_i;
		
		fd++;
	}
	
	
	pd = [patchstore_i elementAt: 0];
	
	for (i=0 ; i<numpatches ; i++)
	{
		image_i = [[NXBitmapImageRep alloc]
			initData:			NULL 
			pixelsWide:			pd->width 
			pixelsHigh:			pd->height
			bitsPerSample:		4
			samplesPerPixel:	4 
			hasAlpha:			YES
			isPlanar:			NO 
			colorSpace:			NX_RGBColorSpace 
			bytesPerRow:		pd->width*2
			bitsPerPixel: 		16
		];
		
		block_p += pd->width*2*pd->height;
		pd->image = image_i;
		
		pd++;
	}

	if (block_p - imageblock > imageblocksize)
	{
		printf ("ERROR: cached block size mismatch!  Memory toastage!");
	}
	
}






