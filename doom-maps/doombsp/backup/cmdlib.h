// cmdlib.h

#ifndef __CMDLIB__
#define __CMDLIB__

#ifndef __BYTEBOOL__
#define __BYTEBOOL__
typedef unsigned char 		byte;
typedef enum {false,true} boolean;
#endif

typedef  unsigned short		USHORT;
typedef unsigned long		ULONG;

extern	int	_argc;
extern	char	**_argv;

int filelength (int handle);
int tell (int handle);

void	Error (char *error, ...);
int		CheckParm (char *check);

int 	SafeOpenWrite (char *filename);
int 	SafeOpenRead (char *filename);
void 	SafeRead (int handle, void *buffer, long count);
void 	SafeWrite (int handle, void *buffer, long count);
void 	*SafeMalloc (long size);

long	LoadFile (char *filename, void **bufferptr);
void	SaveFile (char *filename, void *buffer, long count);

void 	DefaultExtension (char *path, char *extension);
void 	DefaultPath (char *path, char *basepath);
void 	ExtractFileBase (char *path, char *dest);

long 	ParseNum (char *str);

short	MotoShort (short l);
short	IntelShort (short l);
long	MotoLong (long l);
long	IntelLong (long l);

void 	GetPalette (byte *pal);
void 	SetPalette (byte *pal);
void 	VGAMode (void);
void 	TextMode (void);

#endif
