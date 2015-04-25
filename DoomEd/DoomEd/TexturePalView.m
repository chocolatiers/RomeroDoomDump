#import	"TexturePalette.h"
#import	"TextureEdit.h"
#import "TexturePalView.h"
#import	"DoomProject.h"

@implementation TexturePalView

//==============================================================
//
//	Init the storage for the Texture Palette dividers
//
//==============================================================
- initFrame:(const NXRect *)frameRect
{
	dividers_i = [	[ Storage alloc ]
				initCount:		0
				elementSize:	sizeof (divider_t )
				description:	NULL ];
				
	[super	initFrame:frameRect];
	return self;
}

//==============================================================
//
//	Add a Texture Palette divider (new set of textures)
//
//==============================================================
- addDividerX:(int)x Y:(int)y String:(char *)string;
{
	divider_t		d;
	
	d.x = x;
	d.y = y;
	strcpy (d.string, string );
	[dividers_i	addElement:&d ];
	
	return self;
}

- dumpDividers
{
	[dividers_i	empty];
	return self;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	int		count;
	texpal_t	*t;
	NXRect	r;
	int		max, i;
	divider_t	*d;
	
	//
	// draw selected texture outline
	//
	if ([texturePalette_i	currentSelection] >= 0)
	{
		t = [texturePalette_i getTexture:[texturePalette_i currentSelection]];
		r = t->r;
		r.origin.x -= SPACING/2;
		r.origin.y -= SPACING/2;
		r.size.width += SPACING;
		r.size.height += SPACING;
		DE_DrawOutline(&r);
	}
	
	//
	// draw textures
	//
	count = 0;
	while ((t = [texturePalette_i	getNewTexture:count++]) != NULL)
		if (NXIntersectsRect(&rects[0],&t->r) == YES)
			[t->image	composite:NX_COPY	toPoint:&t->r.origin];
	
	//
	//	Draw texture set divider text
	//
	PSselectfont("Helvetica-Bold",12);
	PSrotate ( 0 );
	max = [dividers_i	count ];
	for (i = 0; i < max; i++)
	{
		d = [dividers_i	elementAt:i ];
		PSsetgray ( 0 );
		PSmoveto( d->x,d->y );
		PSshow ( d->string );
		PSstroke ();

		PSsetrgbcolor ( 148,0,0 );
		PSmoveto ( d->x, d->y + 12 );
		PSlineto ( bounds.size.width - SPACING, d->y + 12 );

		PSmoveto ( d->x, d->y - 2 );
		PSlineto ( bounds.size.width - SPACING, d->y - 2 );
		PSstroke ();
	}
	
	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int		i,texcount,oldwindowmask, which;
	texpal_t	*t;

	oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	texcount = [texturePalette_i	getNumTextures];
	for (i = texcount - 1;i >= 0;i--)
	{
		t = [texturePalette_i		getNewTexture:i];
		if (NXPointInRect(&loc,&t->r) == YES)
		{
			which = [texturePalette_i	selectTextureNamed:t->name ];
			if (theEvent->data.mouse.click == 2)
			{
				[textureEdit_i	menuTarget:NULL];
				[textureEdit_i	newSelection:which];
				break;
			}
		}
	}
	return self;
}

@end
