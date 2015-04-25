// lbmfunctions.h

#import	"idfunctions.h"

//		byte				lbmpalette[256][3];	// 8 bit precision
//		byte				vgapalette[256][3];	// 6 bit precision
//		unsigned short	shortpalette[256];	// 4 bit precision with 0xf alpha
//		unsigned			longpalette[256];	// 8 bit precision with 0xff alpha

// these are set by LoadRawLBM for the last loaded image
// the buffers are reused unless the pointers are set to NULL
extern	byte		*lbmpalette;
extern	byte		*byteimage;
extern	int		byteimagewidth, byteimageheight;


BOOL	LoadRawLBM (char const *filename);
BOOL 	SaveRawLBM ( char const *filename, byte const *data, int width, int height
	, byte const *palette);

void		LBMpaletteTo16 (byte const *lbmpal, unsigned short *pal);
void		LBMpaletteTo32 (byte const *lbmpal, unsigned *pal);

void		ConvertLBMTo16 (byte const *in, unsigned short *out, int count
	, unsigned short const *shortpal);
void		ConvertLBMTo32 (byte const *in, unsigned *out, int count
	, unsigned const *longpal);

id		Image16FromRawLBM (byte const *data, int width, int height, byte const *palette);
id		Image32FromRawLBM (byte const *data, int width, int height, byte const *palette);

id		Image16FromLBMFile (char const *filename);
id		Image32FromLBMFile (char const *filename);
