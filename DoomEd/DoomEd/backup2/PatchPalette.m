#import "lbmfunctions.h"
#import "wadfiles.h"
#import "PatchPalView.h"
#import "PatchWindow.h"
#import "PatchPalette.h"
#import "EditWorld.h"
#import "DoomProject.h"

 id	patchPalette_i;


@implementation PatchPalette
- init
{
	window_i = NULL;
	patchPalette_i = self;
	return self;
}

- (int)currentSelection
{
	return [window_i	currentViewSelection];
}

- free
{
	int	i;
	apatch_t	*patch;
	
	i = 0;
	while ((patch = [patchImages	getPatch:i++]) != NULL)
		[patch->image	free];
	[patchImages	free];
	[super	free];
	return self;
}

- (apatch_t *) getPatch:(int)which
{
	return [patchImages	elementAt:which];
}

//
// load in all the patches and init storage array
//
- initPatches
{
	int	patchStart, patchEnd, i;
	patch_t *patch;
	byte const *palLBM;
	apatch_t	p;
	NXSize	s;

	W_InitFile([doomproject_i wadfile]);
	palLBM = W_GetName("playpal");
	
	//
	// get inclusive lump #'s for patches
	//
	patchStart = W_CheckNumForName("p_start") + 1;
	patchEnd = W_CheckNumForName("p_end");

	if (patchStart == -1)
	{
		NXRunAlertPanel(	"OOPS!",
						"There are NO PATCHES in the current .WAD file!",
						"Abort Patch Palette",NULL,NULL,NULL);
		W_FreeLump(W_CheckNumForName("playpal"));
		W_CloseFiles();
		return self;
	}
	
	patchImages = [[Storage	alloc]
						initCount:		0
						elementSize:	sizeof(apatch_t)
						description:	"{ffff}@"];
	
	NXSetRect(&p.r,0,0,0,0);
	for (i = patchStart; i < patchEnd; i++)
	{
		NXSize	theSize;
		//
		// load vertically compressed patch and convert to an NXImage
		//
		patch = W_GetLump(i);
		p.image = patchToImage(patch,palLBM,&s);
		//
		// make a copy that's 2 times the size
		//
		p.image_x2 = [p.image	copyFromZone:NXDefaultMallocZone()];
		theSize = s;
		theSize.width *= 2;
		theSize.height *= 2;
		[p.image_x2	setScalable:YES];
		[p.image_x2	setSize:&theSize];
		
		p.r.size = s;
		[patchImages	addElement:&p];
		W_FreeLump(i);
	}
	
	W_CloseFiles();
	return self;
}

- menuTarget:sender
{
	if (![editworld_i laoded])
	{
		NXRunAlertPanel("Oops!",
						"There must be a world loaded to select patches!",
						"OK",NULL,NULL,NULL);
		return self;
	}

	if (!window_i)
		window_i = [[PatchWindow alloc]	init];

	//
	// make sure patches are loaded before window inits
	//	
	[window_i	makeKeyAndOrderFront:self];
	return self;
}


@end

//
// convert a compressed patch to an NXImage with an alpha channel
//
id	patchToImage(patch_t *patchData,byte const *lbmpalette,NXSize *size)
{
	byte			*dest_p;
	NXImageRep *image_i;
	id			fastImage_i;
	unsigned short	shortpal[256];
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
	LBMpaletteTo16 (lbmpalette, shortpal);
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