// cmdlib.c

//=============================================================================

#ifdef NeXT
#include <libc.h>

// don't need huge pointers
#define huge

#define	O_BINARY	0		// don't need binary flag in open
int	_argc;
char	**_argv;

extern	int	errno;

#define	STRCASECMP	strcasecmp

/*
================
=
= filelength
=
================
*/

int filelength (int handle)
{
	struct stat	fileinfo;
    
	if (fstat (handle,&fileinfo) == -1)
	{
		fprintf (stderr,"Error fstating");
		exit (1);
	}

	return fileinfo.st_size;
}

int tell (int handle)
{
	return lseek (handle, 0, L_INCR);
}


#endif

//=============================================================================

#ifdef __BORLANDC__
#include <stdio.h>
#include <stdarg.h>
#include <process.h>
#include <dos.h>
#include <ctype.h>
#include <string.h>
#include <io.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <alloc.h>

#define	STRCASECMP	stricmp

#endif

//=============================================================================


#include "cmdlib.h"

boolean	graphicson = false;

/*
=============================================================================

						MISC FUNCTIONS

=============================================================================
*/

/*
=================
=
= Error
=
= For abnormal program terminations
=
=================
*/

void Error (char *error, ...)
{
	va_list	argptr;

	if (graphicson)
		TextMode ();

	va_start (argptr,error);
	vprintf (error,argptr);
	va_end (argptr);
	printf ("\n");
	exit (1);
}


/*
=================
=
= CheckParm
=
= Checks for the given parameter in the program's command line arguments
=
= Returns the argument number (1 to argc-1) or 0 if not present
=
=================
*/

int CheckParm (char *check)
{
	int		i;
	char	*parm;

	for (i = 1;i<_argc;i++)
	{
		parm = _argv[i];

		if ( !isalpha(*parm) )	// skip - / \ etc.. in front of parm
			if (!*++parm)
				continue;		// parm was only one char

		if ( !STRCASECMP(check,parm) )
			return i;
	}

	return 0;
}




int SafeOpenWrite (char *filename)
{
	int	handle;

	handle = open(filename,O_RDWR | O_BINARY | O_CREAT | O_TRUNC
	, S_IREAD | S_IWRITE);

	if (handle == -1)
		Error ("Error opening %s: %s",filename,strerror(errno));

	return handle;
}

int SafeOpenRead (char *filename)
{
	int	handle;

	handle = open(filename,O_RDONLY | O_BINARY);

	if (handle == -1)
		Error ("Error opening %s: %s",filename,strerror(errno));

	return handle;
}


void SafeRead (int handle, void *buffer, long count)
{
	unsigned	iocount;

	while (count)
	{
		iocount = count > 0x8000 ? 0x8000 : count;
		if (read (handle,buffer,iocount) != iocount)
			Error ("File read failure");
		buffer = (void *)( (byte huge *)buffer + iocount );
		count -= iocount;
	}
}


void SafeWrite (int handle, void *buffer, long count)
{
	unsigned	iocount;

	while (count)
	{
		iocount = count > 0x8000 ? 0x8000 : count;
		if (write (handle,buffer,iocount) != iocount)
			Error ("File write failure");
		buffer = (void *)( (byte huge *)buffer + iocount );
		count -= iocount;
	}
}


void *SafeMalloc (long size)
{
	void *ptr;

#ifdef __BORLANDC__
	ptr = farmalloc (size);
#else
	ptr = malloc (size);
#endif

	if (!ptr)
		Error ("Malloc failure for %lu bytes",size);

	return ptr;
}


/*
==============
=
= LoadFile
=
==============
*/

long	LoadFile (char *filename, void **bufferptr)
{
	int		handle;
	long	length;
	void	*buffer;

	handle = SafeOpenRead (filename);
	length = filelength (handle);
	buffer = SafeMalloc (length);
	SafeRead (handle, buffer, length);
	close (handle);

	*bufferptr = buffer;
	return length;
}


/*
==============
=
= SaveFile
=
==============
*/

void	SaveFile (char *filename, void *buffer, long count)
{
	int		handle;

	handle = SafeOpenWrite (filename);
	SafeWrite (handle, buffer, count);
	close (handle);
}



void DefaultExtension (char *path, char *extension)
{
	char	*src;
//
// if path doesn't have a .EXT, append extension
// (extension should include the .)
//
	src = path + strlen(path) - 1;

	while (*src != '\\' && src != path)
	{
		if (*src == '.')
			return;			// it has an extension
		src--;
	}

	strcat (path, extension);
}

void DefaultPath (char *path, char *basepath)
{
	char	temp[128];

	if (path[0] == '\\')
		return;							// absolute path location
	strcpy (temp,path);
	strcpy (path,basepath);
	strcat (path,temp);
}


void ExtractFileBase (char *path, char *dest)
{
	char	*src;
	int		length;

	src = path + strlen(path) - 1;

//
// back up until a \ or the start
//
	while (src != path && *(src-1) != '\\')
		src--;

//
// copy up to eight characters
//
	memset (dest,0,8);
	length = 0;
	while (*src && *src != '.')
	{
		if (++length == 9)
			Error ("Filename base of %s >8 chars",path);
		*dest++ = toupper(*src++);
	}
}


/*
==============
=
= ParseNum / ParseHex
=
==============
*/

long ParseHex (char *hex)
{
	char	*str;
	long	num;

	num = 0;
	str = hex;

	while (*str)
	{
		num <<= 4;
		if (*str >= '0' && *str <= '9')
			num += *str-'0';
		else if (*str >= 'a' && *str <= 'f')
			num += 10 + *str-'a';
		else if (*str >= 'A' && *str <= 'F')
			num += 10 + *str-'A';
		else
			Error ("Bad hex number: %s",hex);
		str++;
	}

	return num;
}


long ParseNum (char *str)
{
	if (str[0] == '$')
		return ParseHex (str+1);
	if (str[0] == '0' && str[1] == 'x')
		return ParseHex (str+2);
	return atol (str);
}




short	MotoShort (short l)
{
#ifdef NeXT
	return l;
#else
	byte	b1,b2;

	b1 = l&255;
	b2 = (l>>8)&255;

	return (b1<<8) + b2;
#endif
}

short	IntelShort (short l)
{
	return NXSwapLittleShortToHost (l);
}


long	MotoLong (long l)
{
#ifdef NeXT
	return l;
#else
	byte	b1,b2,b3,b4;

	b1 = l&255;
	b2 = (l>>8)&255;
	b3 = (l>>16)&255;
	b4 = (l>>24)&255;

	return ((long)b1<<24) + ((long)b2<<16) + ((long)b3<<8) + b4;
#endif
}

long	IntelLong (long l)
{
	return NXSwapLittleIntToHost (l);
}


/*
============================================================================

						BASIC GRAPHICS

============================================================================
*/

#define PEL_WRITE_ADR   0x3c8
#define PEL_READ_ADR    0x3c7
#define PEL_DATA                0x3c9
#define PEL_MASK                0x3c6

/*
==============
=
= GetPalette
=
= Return an 8 bit / color palette
=
==============
*/

void GetPalette (byte *pal)
{
#ifdef __BORLANDC__
	int	i;

	outp (PEL_READ_ADR,0);
	for (i=0 ; i<768 ; i++)
		pal[i] = inp (PEL_DATA)<<2;
#endif
}

/*
==============
=
= SetPalette
=
= Sets an 8 bit / color palette
=
==============
*/

void SetPalette (byte *pal)
{
#ifdef __BORLANDC__
	int	i;

	outp (PEL_WRITE_ADR,0);
	for (i=0 ; i<768 ; i++)
		outp (PEL_DATA, pal[i]>>2);
#endif
}


void VGAMode (void)
{
	graphicson = true;
#ifdef __BORLANDC__
	asm	mov	ax,0x13
	asm	int	0x10
#endif
}

void TextMode (void)
{
	graphicson = false;
#ifdef __BORLANDC__
	asm	mov	ax,0x3
	asm	int	0x10
#endif
}
