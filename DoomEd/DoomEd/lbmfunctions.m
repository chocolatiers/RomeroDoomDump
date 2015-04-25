#include <appkit/appkit.h>



typedef unsigned char byte;

// exception code
#define LBMERR	NX_APPBASE

#define	BASEBYTEIMAGESIZE	64000

byte		*lbmpalette = NULL;
int		byteimagesize;
byte		*byteimage = NULL;
int		byteimagewidth, byteimageheight;

/*
============================================================================

						LBM STUFF

============================================================================
*/

#define PEL_WRITE_ADR		0x3c8
#define PEL_READ_ADR		0x3c7
#define PEL_DATA			0x3c9

#if 0
#define FORMID	('M'+('R'<<8)+((long)'O'<<16)+((long)'F'<<24))
#define ILBMID	('M'+('B'<<8)+((long)'L'<<16)+((long)'I'<<24))
#define PBMID   	(' '+('M'<<8)+((long)'B'<<16)+((long)'P'<<24))
#define BMHDID  	('D'+('H'<<8)+((long)'M'<<16)+((long)'B'<<24))
#define BODYID 	('Y'+('D'<<8)+((long)'O'<<16)+((long)'B'<<24))
#define CMAPID  	('P'+('A'<<8)+((long)'M'<<16)+((long)'C'<<24))
#else
#define FORMID	(((long)'M'<<24)+((long)'R'<<16)+((long)'O'<<8)+((long)'F'))
#define ILBMID	(((long)'M'<<24)+((long)'B'<<16)+((long)'L'<<8)+((long)'I'))
#define PBMID   (((long)' '<<24)+((long)'M'<<16)+((long)'B'<<8)+((long)'P'))
#define BMHDID  (((long)'D'<<24)+((long)'H'<<16)+((long)'M'<<8)+((long)'B'))
#define BODYID 	(((long)'Y'<<24)+((long)'D'<<16)+((long)'O'<<8)+((long)'B'))
#define CMAPID  (((long)'P'<<24)+((long)'A'<<16)+((long)'M'<<8)+((long)'C'))
#endif

typedef unsigned char	UBYTE;
typedef short			WORD;
typedef unsigned short	UWORD;
typedef long			LONG;

typedef enum
{
	ms_none,
	ms_mask,
	ms_transcolor,
	ms_lasso
} mask_t;

typedef enum
{
	cm_none,
	cm_rle1
} compress_t;

typedef struct
{
	UWORD		w,h;
	WORD		x,y;
	UBYTE		nPlanes;
	UBYTE		masking;
	UBYTE		compression;
	UBYTE		pad1;
	UWORD		transparentColor;
	UBYTE		xAspect,yAspect;
	WORD		pageWidth,pageHeight;
} bmhd_t;

//
// things that might need to be freed on an exception
//
NXStream	*filestream;		// the memory map of the lbm file
byte			*byteimage;			// the decompressed lbm image, expanded to 8 bits/pixel
unsigned		*meschedimage;		// 32 bit truecolor 
id			imagerep;			// NXBitmapImageRep for meschedimage

//
// this stuff will remain current until another image is loaded
//
bmhd_t		bmhd;
unsigned		intpalette[256];		// (red<<24) + (green<<16) + (blue<<8) + 255


long	Align (long l)
{
	if (l&1)
		return l+1;
	return l;
}



/*
================
=
= LBMRLEdecompress
=
= Source must be evenly aligned!
=
================
*/

byte  const *LBMRLEDecompress (byte const *source, byte *unpacked, int bpwidth)
{
	int 	count;
	byte	b,rept;

	count = 0;

	do
	{
		rept = *source++;

		if (rept > 0x80)
		{
			rept = (rept^0xff)+2;
			b = *source++;
			memset(unpacked,b,rept);
			unpacked += rept;
		}
		else if (rept < 0x80)
		{
			rept++;
			memcpy(unpacked,source,rept);
			unpacked += rept;
			source += rept;
		}
		else
			rept = 0;		// rept of 0x80 is NOP

		count += rept;

	} while (count<bpwidth);

	if (count>bpwidth)
		NX_RAISE (LBMERR, "Decompression exceeded width", 0);


	return source;
}


#define BPLANESIZE	128
byte	bitplanes[9][BPLANESIZE];	// max size 1024 by 9 bit planes

/*
==================
=
= DecompressRLEPBM
=
= Decompresses the body chunk
=
==================
*/

void DecompressRLEPBM (byte const *source, byte *dest, int width, int height)
{
	int		y;
	
	for (y=0 ; y<height ; y++, dest += width)
		source = LBMRLEDecompress (source, dest , width);
}


/*
==================
=
= ExtractUncompressedPBM
=
=  Just gets rid of the padding bytes if present
=
==================
*/

void ExtractUncompressedPBM (byte const *source, byte *dest, int width, int height)
{
	int		y;
	
	if (width & 1)
	{
		for (y=0 ; y<height ; y++, dest += width)
		{
			memcpy (dest,source,width);
			source += width+1;
		}
	}
	else
		memcpy (dest, source, width*height);	// no padding
}


/*
==========================================================================
=
= LoadRawLBM
=
= Upon success:
= 	byteimage, byteimagewidth, byteimageheight, and lbmpalette will be full
=
= The byteimage and lbmpalette buffers are normally reused between calls, but you can copy the
= pointers and set them to NULL to force reallocation
=
==========================================================================
*/

BOOL	LoadRawLBM (char const *filename)
{
	byte	 	*LBM_P,  *LBMEND_P;
	
	long		formtype,formlength;
	long		chunktype,chunklength;

	byte		*cmap;
	byte	  	*body;

	char		*streambuf;
	int		streamlen, streammaxlen;
	int		size;
	
//===========
NX_DURING
//===========
	
	cmap = NULL;
	body = NULL;
	filestream = NULL;
//printf ("Filename: %s\n",filename);	
//
// load the LBMwith file mapping
//	
	filestream = NXMapFile (filename, NX_READONLY);
	if (!filestream)
		NX_RAISE(LBMERR, "Couldn't map file",0);

	NXGetMemoryBuffer(filestream, &streambuf, &streamlen, &streammaxlen);
	

//
// parse the LBM header
//
	LBM_P = streambuf;

	if ( *(long  *)LBM_P != FORMID )
	   NX_RAISE (LBMERR, "No FORM ID at start of file!", 0);

	LBM_P += 4;
	formlength = *(long  *)LBM_P;
	LBM_P += 4;
	LBMEND_P = LBM_P + Align(formlength);

	formtype = *(long  *)LBM_P;

	if (formtype != ILBMID && formtype != PBMID)
		NX_RAISE (LBMERR, "Form not ILBM or PBM",0);

	LBM_P += 4;

//
// find the important chunks
//
	while (LBM_P < LBMEND_P)
	{
		chunktype = *(long  *)LBM_P;
		LBM_P += 4;
		chunklength = *(long  *)LBM_P;
		LBM_P += 4;

		switch (chunktype)
		{
		case BMHDID:
			memcpy (&bmhd,LBM_P,sizeof(bmhd));
			break;

		case CMAPID:
			cmap = LBM_P;
			break;

		case BODYID:
			body = LBM_P;
			break;
		}

		LBM_P += Align(chunklength);
	}

//
// all done parsing
// cmap and pic should be filled in
//
	if ( bmhd.compression != cm_rle1 && bmhd.compression != cm_none)
		NX_RAISE (LBMERR, "Unknown compression type", 0);
	if (!cmap)
		NX_RAISE (LBMERR, "No CMAP in file", 0);
	if (!body)
		NX_RAISE (LBMERR, "No BODY in file", 0);
	if (formtype != PBMID)
		NX_RAISE (LBMERR,"Can't read interlaced LBMS yet...",0);

//
// allocate new buffers if needed and copy info
//
	if (!byteimage)
	{
		byteimagesize = BASEBYTEIMAGESIZE;
		byteimage = malloc (byteimagesize);
		if (!byteimage)
			NX_RAISE(LBMERR, "Couldn't allocate byteimage",0);
	}
	
	if (!lbmpalette)
	{
		lbmpalette = malloc (768);
		if (!lbmpalette)
			NX_RAISE(LBMERR, "Couldn't allocate lbmpalette",0);
	}
	memcpy (lbmpalette, cmap, 768);
	
	byteimagewidth = bmhd.w;
	byteimageheight = bmhd.h;
	
	size = byteimagewidth * byteimageheight;
	
	if (size > byteimagesize)
	{
		byteimage = realloc (&byteimage, byteimagesize);
		if (!byteimage)
			NX_RAISE(LBMERR, "Couldn't realloc byteimage",0);
	}

	if (bmhd.compression == cm_none)	
		ExtractUncompressedPBM (body, byteimage, byteimagewidth, byteimageheight);
	else if (bmhd.compression == cm_rle1)	
		DecompressRLEPBM (body, byteimage, byteimagewidth, byteimageheight);
		
	NX_VALRETURN(YES);
	
//===========
NX_HANDLER
//===========
	if (filestream)
		NXCloseMemory(filestream, NX_FREEBUFFER);
	if (meschedimage)
		free (meschedimage);
		
	if (NXLocalHandler.code != LBMERR)
	{
		NXRunAlertPanel ("LBM Error", "Unknown exception", NULL, NULL, NULL);
		NX_RERAISE();
	}
	else
		NXRunAlertPanel ("LBM Error", NXLocalHandler.data1, NULL, NULL, NULL);		
//===========
NX_ENDHANDLER
//===========
	return NO;
}


/*
==========================================================================
=
= SaveRawLBM
=
= Writes out a VGA lbm in PBM format
= The palette values should be in the full 0-256 scale
= Returns NO on error
==========================================================================
*/

bmhd_t	basebmhd = {320,200,0,0,8,0,0,0,0,5,6,320,200};

BOOL SaveRawLBM ( char const *filename, byte const *data, int width, int height
	, byte const *palette)
{
    byte		*lbm,*lbmptr;
    long		*formlength,*bmhdlength,*cmaplength,*bodylength;
    long		length, written;
    int			handle;
   
printf ("Writing %s (%i*%i) (%p, %p)...\n",filename, width,height,(void *)data,(void *)palette);

	lbm = lbmptr = malloc (width*height+2048);
	if (!lbm)
	{
		NXLogError ("couldn't malloc %i bytes\n",width*height+2048);
		return NO;
	}
   
	if (!palette  || !data)
	{
		NXLogError ("SaveLBM called with palette: %p  data: %p\n", palette, data);
		return NO;
	}
	
//
// start FORM
//
	*((long *)lbmptr)++ = FORMID;
	
	formlength = (long *)lbmptr;
	lbmptr+=4;			// leave space for length
	
	*((long *)lbmptr)++ = PBMID;

//
// write BMHD
//
	*((long *)lbmptr)++ = BMHDID;
	
	bmhdlength = (long *)lbmptr;
	lbmptr+=4;			// leave space for length
	
	basebmhd.w = width;
	basebmhd.h = height;
	basebmhd.w = NXSwapHostShortToBig(basebmhd.w);
	basebmhd.h = NXSwapHostShortToBig(basebmhd.h);
	basebmhd.pageWidth = NXSwapHostShortToBig(basebmhd.pageWidth);
	basebmhd.pageHeight = NXSwapHostShortToBig(basebmhd.pageHeight);
	memcpy (lbmptr,&basebmhd,sizeof(basebmhd));
	lbmptr += sizeof(basebmhd);
	
	length = lbmptr-(byte *)bmhdlength-4;
	*bmhdlength = NXSwapHostLongToBig(length);
	if (length&1)
		*lbmptr++ = 0;		// pad chunk to even offset
	
//
// write CMAP
//
	*((long *)lbmptr)++ = CMAPID;
	
	cmaplength = (long *)lbmptr;
	lbmptr+=4;			// leave space for length
	
	memcpy (lbmptr,palette,768);
	lbmptr += 768;
	
	length = lbmptr-(byte *)cmaplength-4;
	*cmaplength = NXSwapHostLongToBig(length);
	if (length&1)
		*lbmptr++ = 0;		// pad chunk to even offset
	
//
// write BODY
//
	*((long *)lbmptr)++ = BODYID;
	
	bodylength = (long *)lbmptr;
	lbmptr+=4;			// leave space for length
	
	memcpy (lbmptr,data,width*height);
	lbmptr += width*height;
	
	length = lbmptr-(byte *)bodylength-4;
	*bodylength = NXSwapHostLongToBig(length);
	if (length&1)
		*lbmptr++ = 0;		// pad chunk to even offset
	
//
// done
//
	length = lbmptr-(byte *)formlength-4;
	*formlength = NXSwapHostLongToBig(length);
	if (length&1)
		*lbmptr++ = 0;		// pad chunk to even offset

//
// write the file out
//   
	handle = open (filename,O_RDWR | O_CREAT | O_TRUNC,0666);
	if (handle == -1)
	{
		free (lbm);
		NXLogError ("Error opening %s: %s\n", filename, strerror(errno));
		return NO;
	}
	
	length = lbmptr-lbm;
	written = write (handle,lbm,length);
	if (written != length)
	{
		close (handle);
		unlink (filename);
		free (lbm);
		if (written == -1)
			NXLogError ("Error writing to %s: %s\n", filename, strerror(errno));
		else
			NXLogError ("Only wrote %i of %i bytes to %s: %s\n", filename);
		return NO;
	}
	
	close (handle);
	free (lbm);
	
	return YES;
}


/*
==========================================================================
=
= LBMpaletteTo??
=
==========================================================================
*/

void		LBMpaletteTo16 (byte const *lbmpal, unsigned short *pal)
{
	int	i, r, g, b;

	for (i=0 ; i<256 ; i++)
	{
		r = (*lbmpal++)>>4;
		g = (*lbmpal++)>>4;
		b = (*lbmpal++)>>4;
		pal[i] = NXSwapBigShortToHost( (r<<12) + (g<<8) + (b<<4) + 15 );
	}
}

void		LBMpaletteTo32 (byte const *lbmpal, unsigned *pal)
{
	int	i, r, g, b;

	for (i=0 ; i<256 ; i++)
	{
		r = *lbmpal++;
		g = *lbmpal++;
		b = *lbmpal++;
		pal[i] = NXSwapBigLongToHost( (r<<24) + (g<<16) + (b<<8) + 255 );
	}
}

/*
==========================================================================
=
= ConvertLBMTo??
=
==========================================================================
*/

void		ConvertLBMTo16 (byte const *in, unsigned short *out, int count
	, unsigned short const *shortpal)
{
	byte	const *stop;
	
	stop = in + count;
	while (in != stop)
		*out++ = shortpal[*in++];
}

void		ConvertLBMTo32 (byte const *in, unsigned *out, int count
	, unsigned const *longpal)
{
	byte	const *stop;
	
	stop = in + count;
	while (in != stop)
		*out++ = longpal[*in++];
}

/*
==========================================================================
=
= Image??FromRawLBM
=
==========================================================================
*/

id		Image16FromRawLBM (byte const *data, int width, int height, byte const *palette)
{
	byte			*dest_p;
	id			image_i;
	unsigned short	shortpal[256];

//
// make an NXimage to hold the data
//
	image_i = [[NXBitmapImageRep alloc]
		initData:			NULL 
		pixelsWide:		width 
		pixelsHigh:		height
		bitsPerSample:	4
		samplesPerPixel:	3 
		hasAlpha:		NO 
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
	LBMpaletteTo16 (palette, shortpal);
	ConvertLBMTo16 (data, (unsigned short *)dest_p, width*height, shortpal);

	return image_i;	
}


id		Image32FromRawLBM (byte const *data, int width, int height, byte const *palette)
{
	byte			*dest_p;
	id			image_i;
	unsigned		longpal[256];

//
// make an NXimage to hold the data
//
	image_i = [[NXBitmapImageRep alloc]
		initData:			NULL 
		pixelsWide:		width 
		pixelsHigh:		height
		bitsPerSample:	8
		samplesPerPixel:	3 
		hasAlpha:		NO 
		isPlanar:			NO 
		colorSpace:		NX_RGBColorSpace 
		bytesPerRow:		width*4
		bitsPerPixel: 		32
	];

	if (!image_i)
		return nil;
			
//
// translate the picture
//
	dest_p = [(NXBitmapImageRep *)image_i data];
	LBMpaletteTo32 (palette, longpal);
	ConvertLBMTo32 (data, (unsigned  *)dest_p, width*height, longpal);

	return image_i;	
}


/*
==========================================================================
=
= Image??FromLBMFile
=
==========================================================================
*/

id		Image16FromLBMFile (char const *filename)
{
	if (!LoadRawLBM (filename))
		return nil;
	return Image16FromRawLBM (byteimage, byteimagewidth, byteimageheight, lbmpalette);
}


id		Image32FromLBMFile (char const *filename)
{
	if (!LoadRawLBM (filename))
		return nil;
	return Image32FromRawLBM (byteimage, byteimagewidth, byteimageheight, lbmpalette);
}



