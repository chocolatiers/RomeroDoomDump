#import	"EditWorld.h"
#import	"TexturePalette.h"
#import	"TextureRemapper.h"

id	textureRemapper_i;

@implementation TextureRemapper

//===================================================================
//
//	REMAP TEXTURES IN MAP
//
//===================================================================
- init
{
	textureRemapper_i = self;
	
	remapper_i = [ [ Remapper	alloc ]
				setFrameName:"TextureRemapper"
				setPanelTitle:"Texture Remapper"
				setBrowserTitle:"List of textures to be remapped"
				setRemapString:"Texture"
				setDelegate:self ];
	return self;
}

//===================================================================
//
//	Bring up panel
//
//===================================================================
- menuTarget:sender
{
	[remapper_i	showPanel];
	return self;
}

- addToList:(char *)orgname to:(char *)newname;
{
	[remapper_i	addToList:orgname to:newname];
	return self;
}

//===================================================================
//
//	Delegate methods
//
//===================================================================
- (char *)getOriginalName
{
	return [texturePalette_i	getSelTextureName];
}

- (char *)getNewName
{
	return [texturePalette_i	getSelTextureName];
}

- (int)doRemap:(char *)oldname to:(char *)newname
{
	int		i;
	int		linenum;
	int		flag;
	
	linenum = 0;
	for (i = 0;i < numlines; i++)
	{
		flag = 0;
		// SIDE 0
		if (!strcasecmp ( oldname,lines[i].side[0].bottomtexture))
		{
			strcpy(lines[i].side[0].bottomtexture, newname );
			flag++;
		}
		if (!strcasecmp( oldname,lines[i].side[0].midtexture))
		{
			strcpy(lines[i].side[0].midtexture, newname );
			flag++;
		}
		if (!strcasecmp( oldname ,lines[i].side[0].toptexture))
		{
			strcpy(lines[i].side[0].toptexture, newname );
			flag++;
		}

		// SIDE 1
		if (!strcasecmp ( oldname,lines[i].side[1].bottomtexture))
		{
			strcpy(lines[i].side[1].bottomtexture, newname );
			flag++;
		}
		if (!strcasecmp( oldname,lines[i].side[1].midtexture))
		{
			strcpy(lines[i].side[1].midtexture, newname );
			flag++;
		}
		if (!strcasecmp( oldname ,lines[i].side[1].toptexture))
		{
			strcpy(lines[i].side[1].toptexture, newname );
			flag++;
		}
		
		if (flag)
		{
			printf("Remapped texture %s to %s.\n",oldname,newname);
			linenum++;
		}
	}
	
	return linenum;
}

- finishUp
{
	return self;
}

@end
