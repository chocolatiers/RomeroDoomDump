// cmdlib.h

#ifndef __CMDLIB__
#define __CMDLIB__

#ifdef __NeXT__
#include <libc.h>
#include <errno.h>
#include <ctype.h>

#else

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <io.h>
#include <direct.h>
#include <process.h>
#include <dos.h>
#include <stdarg.h>
#include <conio.h>
#include <bios.h>

#endif

#ifdef __NeXT__
#define strcmpi strcasecmp
#define stricmp strcasecmp
char *getcwd (char *path, int length);
char *strupr (char *in);
int filelength (int handle);
int tell (int handle);
#endif

#ifndef __BYTEBOOL__
#define __BYTEBOOL__
typedef enum {false, true} boolean;
typedef unsigned char byte;
#endif


#ifndef __NeXT__
#define PATHSEPERATOR   '\\'
#endif

#ifdef __NeXT__

#define O_BINARY        0
#define PATHSEPERATOR   '/'

#endif

int		GetKey (void);

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
void 	StripFilename (char *path);
void 	StripExtension (char *path);
void 	ExtractFileBase (char *path, char *dest);

long 	ParseNum (char *str);

short	BigShort (short l);
short	LittleShort (short l);
long	BigLong (long l);
long	LittleLong (long l);

extern	byte	*screen;

void 	GetPalette (byte *pal);
void 	SetPalette (byte *pal);
void 	VGAMode (void);
void 	TextMode (void);

#endif
