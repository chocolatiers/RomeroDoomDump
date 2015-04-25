#import <appkit/appkit.h>
#import "cmdlib.h"
#import "doomprint.h"

id 			window_i, view_i;
float		scale = 0.125;
NXRect		worldbounds;
char		*levelname;

BOOL		weapons;
BOOL		powerups;
BOOL		monsters;


/*
===========
=
= BoundLineStore
=
===========
*/

void BoundLineStore (id lines_i, NXRect *r)
{
	int				i,c;
	worldline_t		*line_p;
	
	c = [lines_i count];
	if (!c)
		Error ("BoundLineStore: empty list");
		
	line_p = [lines_i elementAt:0];
	IDRectFromPoints (r, &line_p->p1, &line_p->p2);
	
	for (i=1 ; i<c ; i++)
	{
		line_p = [lines_i elementAt:i];
		IDEnclosePoint (r, &line_p->p1);
		IDEnclosePoint (r, &line_p->p2);
	}	
}


@interface PrintMapView: View

@end

@implementation PrintMapView

- initFrame:(const NXRect *)frameRect
{
	NXRect	scaled;
	float	hscale, vscale;
	
	BoundLineStore (linestore_i, &worldbounds);
	worldbounds.origin.x -= 8;
	worldbounds.origin.y -= 8;
	worldbounds.size.width += 16;
	worldbounds.size.height += 16;
	
	hscale = 8*72 / worldbounds.size.width; 
	vscale = 9.5*72 / worldbounds.size.height;
	scale = hscale < vscale ? hscale : vscale;
	worldbounds.size.height += 30/scale;
	
	scaled.origin.x = 300;
	scaled.origin.y = 80;
	scaled.size.width = worldbounds.size.width*scale;
	scaled.size.height = worldbounds.size.height* scale;
	
	[super initFrame: &scaled];
	
	[self
		setDrawSize:	worldbounds.size.width
		:				worldbounds.size.height];
	[self 
		setDrawOrigin:	worldbounds.origin.x 
		: 				worldbounds.origin.y];

	return self;
}


float	dashes[1] = {10};
float	specdashes[2] = {2, 10};

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	int				i,c;
	worldline_t		*line_p;
	worldthing_t	*thing_p;

	
	c = [linestore_i count];

	PSsetgray (NX_BLACK);	
	
	PSmoveto (bounds.origin.x + 100, bounds.origin.y+bounds.size.height - 24/scale);
	PSselectfont("Helvetica-Bold",24/scale);
	PSrotate ( 0 );
	//PSshow (levelname);
	
	//
	//	Draw lines
	//
	for (i=0 ; i<c ; i++)
	{
		line_p = [linestore_i elementAt:i];
		if (line_p->special)
		{
			PSsetgray (NX_BLACK);	
			PSsetdash(specdashes, 2, 0);
			PSsetlinewidth(8.0);
		}
		else if (line_p->flags & ML_TWOSIDED)
		{
			PSsetgray (0.5);	
			PSsetdash(NULL, 0, 0);
			PSsetlinewidth(8.0);
		}
		else
		{
			PSsetgray (NX_BLACK);	
			PSsetdash(NULL, 0, 0);
			PSsetlinewidth(8.0);
		}
			
		PSmoveto (line_p->p1.x, line_p->p1.y);
		PSlineto (line_p->p2.x, line_p->p2.y);
		PSstroke ();
	}
	
	//
	//	Draw Things
	//
	c = [thingstore_i	count];
	PSsetdash(NULL, 0, 0);
	PSselectfont("Helvetica",5/scale);
	PSrotate(0);
	PSsetgray (NX_BLACK);	
	for (i = 0; i < c; i++)
	{
		thing_p = [thingstore_i	elementAt:i];
		
		if (thing_p->options&16)	// network object?
			continue;
			
		PSmoveto(thing_p->origin.x - 2/scale, thing_p->origin.y - 2/scale);
		//
		//	Print weapons
		//
		if (weapons == YES)
			switch(thing_p->type)
			{
				#if 1
				case 2001:	// shotgun
					PSshow("SG"); break;
				case 2002:	// chaingun
					PSshow("CG"); break;
				case 2003:	// rocket launcher
					PSshow("RL"); break;
				case 2004:	// plasma gun
					PSshow("PG"); break;
				case 2005:	// chainsaw
					PSshow("CS"); break;
				case 2006:	// BFG9000
					PSshow("BFG"); break;
				// DOOM II
				case 82:	// Combat shotgun
					PSshow("DBS"); break;
				
				#else
				
				case 2001:	// shotgun
					PSshow("SG"); break;
				case 2002:	// chaingun
					PSshow("CG"); break;
				case 2003:	// rocket launcher
					PSshow("RL"); break;
				case 2004:	// plasma gun
					PSshow("PG"); break;
				case 2005:	// chainsaw
					PSshow("CS"); break;
				case 2006:	// BFG9000
					PSshow("BFG"); break;
					
				// ammo
				case 2047:	// cell
					PSshow("C"); break;
				case 17:	// cell pack
					PSshow("LC"); break;
				case 2007:	// clip
					PSshow("BU"); break;
				case 2048:	// box of clips
					PSshow("A"); break;
				case 2010:	// single rocket
					PSshow("O"); break;
				case 2046:	// box of rockets
					PSshow("CR"); break;
				case 2008:	// shells (4)
					PSshow("SS"); break;
				case 2049:	// box of shells
					PSshow("BS"); break;
				
				// DOOM II
				case 82:	// Combat shotgun
					PSshow("DS"); break;
				#endif
			}

		//
		//	Monsters
		//
		if (monsters == YES)
			switch(thing_p->type)
			{
				#if 1
				case 1:		// Player 1 start
					PSshow("START"); break;
				case 3003:	// baron of Hell
					PSshow("Br"); break;
				case 3005:	// cacodemon
					PSshow("Cd"); break;
				case 3004:	// possesed human
					PSshow("Fh"); break;
				case 9:		// possesed shotgun human
					PSshow("Fs"); break;
				case 65:	// possesed human commando
					PSshow("Fc"); break;
				case 3002:	// demon
					PSshow("De"); break;
				case 58:	// spectre
					PSshow("Sp"); break;
				case 3006:	// lost soul
					PSshow("Ls"); break;
				case 7:		// spiderdemon
					PSshow("Spider"); break;
				case 16:	// cyberdemon
					PSshow("Cyber"); break;
				case 3001:	// imp
					PSshow("Im"); break;
				// DOOM II
				case 68:	// arachnotron
					PSshow("Ar"); break;
				case 64:	// arch vile
					PSshow("Av"); break;
				case 88:	// boss brain
					PSshow("Boss"); break;
				case 69:	// hell knight
					PSshow("Hk"); break;
				case 67:	// mancubus
					PSshow("Man"); break;
				case 71:	// pain elemental
					PSshow("Pe"); break;
				case 66:	// revenant
					PSshow("Rv"); break;
				case 84:	// wolf ss
					PSshow("Ss"); break;
					
				#else
				
				case 1:		// Player 1 start
					PSshow("Enter"); break;
				case 3003:	// baron of Hell
					PSshow("BH"); break;
				case 3005:	// cacodemon
					PSshow("CD"); break;
				case 3004:	// possesed human
					PSshow("FH"); break;
				case 9:		// possesed shotgun human
					PSshow("FS"); break;
				case 65:	// possesed human commando
					PSshow("FC"); break;
				case 3002:	// demon
					PSshow("D"); break;
				case 58:	// spectre
					PSshow("S"); break;
				case 3006:	// lost soul
					PSshow("LS"); break;
				case 7:		// spiderdemon
					PSshow("SM"); break;
				case 16:	// cyberdemon
					PSshow("CY"); break;
				case 3001:	// imp
					PSshow("I"); break;
				// DOOM II
				case 68:	// arachnotron
					PSshow("AR"); break;
				case 64:	// arch vile
					PSshow("AV"); break;
				case 88:	// boss brain
					PSshow("JR"); break;
				case 69:	// hell knight
					PSshow("HK"); break;
				case 67:	// mancubus
					PSshow("M"); break;
				case 71:	// pain elemental
					PSshow("PE"); break;
				case 66:	// revenant
					PSshow("R"); break;
				case 84:	// wolf ss
					PSshow("N"); break;
				#endif
			}
	}
	PSstroke();

	//
	//	Print powerups
	//
	if (powerups == YES)
	{
		PSselectfont("Courier-Bold",7/scale);
		for (i = 0; i < c; i++)
		{
			thing_p = [thingstore_i	elementAt:i];

			if (thing_p->options&16)	// network object?
				continue;
			
			PSmoveto(thing_p->origin.x - 2/scale, thing_p->origin.y - 2/scale);
			switch(thing_p->type)
			{
				#if 1
				case 2022:	// invulnerable
					PSshow("iv"); break;
				case 2023:	// berserk
					PSshow("bs"); break;
				case 2024:	// invisible
					PSshow("in"); break;
				case 2025:	// radiation suit
					PSshow("rs"); break;
				case 2026:	// computer area map
					PSshow("cm"); break;
				case 2045:	// light amp goggles
					PSshow("lg"); break;
				case 8:		// backpack
					PSshow("bp"); break;
				case 2013:	// soul sphere
					PSshow("ss"); break;
				case 2018:	// security armor
					PSshow("sa"); break;
				case 2019:	// combat armor
					PSshow("ca"); break;
				
				case 5:		// blue card
					PSshow("bc"); break;
				case 40:	// blue skull
					PSshow("bs"); break;
				case 13:	// red card
					PSshow("rc"); break;
				case 38:	// red skull
					PSshow("rs"); break;
				case 6:		// yellow card
					PSshow("yc"); break;
				case 39:	// yellow skull
					PSshow("ys"); break;
					
				// DOOM II
				case 83:	// megasphere
					PSshow("mg"); break;
				
				#else
				
				case 2022:	// invulnerable
					PSshow("IV"); break;
				case 2023:	// berserk
					PSshow("B"); break;
				case 2024:	// invisible
					PSshow("IN"); break;
				case 2025:	// radiation suit
					PSshow("RS"); break;
				case 2026:	// computer area map
					PSshow("CM"); break;
				case 2045:	// light amp goggles
					PSshow("LG"); break;
				case 8:		// backpack
					PSshow("BP"); break;
				case 2013:	// soul sphere
					PSshow("SO"); break;
				case 2018:	// security armor
					PSshow("A1"); break;
				case 2019:	// combat armor
					PSshow("A2"); break;
				case 2012:	// medikit
					PSshow("MK"); break;
				case 2011:	// stimpack
					PSshow("SP"); break;
				case 2015:	// spiritual armor
					PSshow("SA"); break;
					
				
				case 5:		// blue card
					PSshow("Blue Key"); break;
				case 40:	// blue skull
					PSshow("bs"); break;
				case 13:	// red card
					PSshow("Red Key"); break;
				case 38:	// red skull
					PSshow("rs"); break;
				case 6:		// yellow card
					PSshow("Yellow Key"); break;
				case 39:	// yellow skull
					PSshow("ys"); break;
					
				// DOOM II
				case 83:	// megasphere
					PSshow("MS"); break;
				#endif
			}
		}
		PSstroke();
	}
	
	NXPing ();
	return self;
}

- (BOOL)getRect:(NXRect *)theRect forPage:(int)page
{
	if (page != 1)
		return NO;
		
	[self getBounds: theRect];
	
	return YES;
}

- (BOOL)knowsPagesFirst:(int *)firstPageNum last:(int *)lastPageNum
{
	*lastPageNum = 1;
	return YES;
}

BOOL	runpanel = NO;

- (BOOL)shouldRunPrintPanel: view
{
	return runpanel;
}

@end



/*
==================
=
= main
=
==================
*/

int main (int argc, char **argv)
{	
	int		i;
	NXRect	scaled;
	char	name[256];
	
	i = 1;
	if (argc > 2 && !strcmp (argv[1] , "-panel") )
	{
		runpanel = YES;
		i++;
	}
	if (argc > 2 && !strcmp (argv[i] , "-weapons") )
	{
		printf("Printing all weapons\n");
		weapons = YES;
		i++;
	}
	if (argc > 2 && !strcmp (argv[i] , "-powerups") )
	{
		printf("Printing all powerUps\n");
		powerups = YES;
		i++;
	}
	if (argc > 2 && !strcmp (argv[i] , "-monsters") )
	{
		printf("Printing all monsters\n");
		monsters = YES;
		i++;
	}
		
	NXApp = [Application new];
	for ( ; i< argc ; i++)
	{
		ExtractFileBase (argv[i], name);
		levelname = name;
		LoadDoomMap (argv[i]);
		view_i = [[PrintMapView alloc] init];
		[view_i getFrame: &scaled];
		
		window_i =
		[[Window alloc]
			initContent:	&scaled
			style:			NX_TITLEDSTYLE
			backing:		NX_RETAINED
			buttonMask:		0
			defer:			NO
		];
		
		[window_i setContentView: view_i];
		[window_i display];
//		[window_i orderFront: nil];
		
		[view_i printPSCode: view_i];

// NXPing ();
// getchar ();
		[window_i free];
	}
	[NXApp free];
	return 0;
}
