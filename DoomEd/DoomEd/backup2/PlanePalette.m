#import "lbmfunctions.h"
#import "wadfiles.h"
#import "PatchPalette.h"
#import "PlanePalette.h"
#import "PlaneWindow.h"
#import "EditWorld.h"
#import "DoomProject.h"

id	planePalette_i;

@implementation PlanePalette

- (apatch_t *) getPlane:(int)which
{
	return [planeImages	elementAt:which];
}

- (int) currentSelection
{
	return [window_i	currentViewSelection];
}

- init
{
	window_i = NULL;
	planePalette_i = self;
	
	return self;
}

- menuTarget:sender
{
	if (!editworld_i)
	{
		NXRunAlertPanel("Oops!",
						"There must be a world loaded to select planes!",
						"OK",NULL,NULL,NULL);
		return self;
	}
	
	if (!window_i)
	{
		int	planeStart, planeEnd, i;
		byte const *palLBM;
		byte *plane;
		apatch_t	p;
	
		W_InitFile([doomproject_i wadfile]);
		palLBM = W_GetName("playpal");
		
		//
		// get inclusive lump #'s for patches
		//
		planeStart = W_CheckNumForName("f_start") + 1;
		planeEnd = W_CheckNumForName("f_end");
	
		if (planeStart == -1)
		{
			NXRunAlertPanel(	"OOPS!",
							"There are NO FLAT PLANES in the current .WAD file!",
							"Abort Plane Palette",NULL,NULL,NULL);
			W_FreeLump(W_CheckNumForName("playpal"));
			W_CloseFiles();
			return self;
		}
		
		planeImages = [[Storage	alloc]
							initCount:		0
							elementSize:	sizeof(apatch_t)
							description:	"{ffff}@"];
		
		NXSetRect(&p.r,0,0,0,0);
		for (i = planeStart; i < planeEnd; i++)
		{
			//
			// load vertically compressed patch and convert to an NXImage
			//
			plane = W_GetLump(i);
			p.image = planeToImage(plane,palLBM);
			p.r.size.width = 64;
			p.r.size.height = 64;
			[planeImages	addElement:&p];
			W_FreeLump(i);
		}
		
		W_CloseFiles();
		window_i = [[PlaneWindow alloc]	init];
	}
	
	//
	// make sure patches are loaded before window inits
	//	
	[window_i	makeKeyAndOrderFront:self];
	return self;
}

@end

//
// convert a raw 64x64 to an NXImage without an alpha channel
//
id	planeToImage(byte *planeData,byte const *lbmpalette)
{
	short		*dest_p;
	NXImageRep *image_i;
	id			fastImage_i;
	unsigned short	shortpal[256];
	unsigned		i;

	//
	// make an NXimage to hold the data
	//
	image_i = [[NXBitmapImageRep alloc]
		initData:			NULL 
		pixelsWide:		64 
		pixelsHigh:		64
		bitsPerSample:	4
		samplesPerPixel:	3 
		hasAlpha:		NO
		isPlanar:			NO 
		colorSpace:		NX_RGBColorSpace 
		bytesPerRow:		128
		bitsPerPixel: 		16
	];

	if (!image_i)
		return nil;
				
	//
	// translate the picture
	//
	LBMpaletteTo16 (lbmpalette, shortpal);
	 (unsigned char *)dest_p =[(NXBitmapImageRep *)image_i data];
	memset(dest_p,0,64 * 64 * sizeof(short));
	
	for (i = 0;i < 64*64; i++)
		*(dest_p++) = shortpal[*(planeData++)];

	fastImage_i = [[NXImage	alloc]
							init];
	[fastImage_i	useRepresentation:(NXImageRep *)image_i];	
	return fastImage_i;
}
