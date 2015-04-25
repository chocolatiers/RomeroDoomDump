// idglobal.h

// this file should be included by every file in the project

#ifndef __IDGLOBAL__
#define __IDGLOBAL__

#define PARMCHECK

#ifndef __BYTEBOOL__
#define __BYTEBOOL__
typedef unsigned char byte;
typedef enum {false, true} boolean;
#endif

void IO_Error (char *error, ...);

#ifdef NeXT
unsigned short ShortSwap (unsigned short dat);
unsigned LongSwap (unsigned dat);
#define SHORT(x)	ShortSwap(x)
#define LONG(x)	LongSwap(x)
#else
#define SHORT(x)	(x)
#define LONG(x)	(x)
#endif


#endif
