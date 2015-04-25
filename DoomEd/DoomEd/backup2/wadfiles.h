// wadfiles.h

#ifndef __DISK__
#define __DISK__

#ifndef __IDGLOBAL__
#include "idglobal.h"
#endif

#include <stdio.h>

#define	MAXFILES	20

//==============================================

typedef struct
{
	int		filehandle;
	int		filepos;
	int		size;
	char		name[8];
} lumpinfo_t;

//==============================================

extern	lumpinfo_t	*lumpinfo;		// location of each lump on disk
extern	int			numlumps;

extern	void		**lumpmain;		// pointers to the lumps in main memory
									// NULL if not loaded

extern	FILE		*debugstream;	// misc io stream

//==============================================

void	W_InitMultipleFiles (char **filenames);
void	W_InitFile (char *filename);
void W_CloseFiles (void);

int		W_CheckNumForName (char *name);
int		W_GetNumForName (char *name);

void	*W_GetLump (int lump);
void	*W_GetName (char *name);
void	W_ReadLump (int lump, void *dest);
void	W_FreeLump (unsigned lump);
void	W_WriteLump (unsigned lump);

void	W_OpenDebug (void);
void	W_CloseDebug (void);

#endif
