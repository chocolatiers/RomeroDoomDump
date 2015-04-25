
#import "PreferencePanel.h"
#import "MapWindow.h"

id	prefpanel_i;

char		*ucolornames[NUMCOLORS] =
{
	"back_c",
	"grid_c",
	"tile_c",
	"selected_c",
	"point_c",
	"onesided_c",
	"twosided_c",
	"area_c",
	"thing_c",
};
	
@implementation PreferencePanel

+ initialize
{
	static NXDefaultsVector defaults = 
	{
		{"back_c","1:1:1"},
		{"grid_c","0.8:0.8:0.8"},
		{"tile_c","0.5:0.5:0.5"},
		{"selected_c","1:0:0"},

		{"point_c","0:0:0"},
		{"onesided_c","0:0:0"},
		{"twosided_c","0.5:1:0.5"},
		{"area_c","1:0:0"},
		{"thing_c","1:1:0"},
		{NULL}
	};

	NXRegisterDefaults(APPDEFAULTS, defaults);

	return self;
}

- getColor: (NXColor *)clr fromString: (char const *)string
{
	float	r,g,b;
	
	sscanf (string,"%f:%f:%f",&r,&g,&b);
	*clr = NXConvertRGBToColor(r,g,b);
	return self;
}

- getString: (char *)string fromColor: (NXColor *)clr
{
	char		temp[40];
	float	r,g,b;
	
	r = NXRedComponent(*clr);
	g = NXGreenComponent(*clr);
	b = NXBlueComponent(*clr);
	
	sprintf (temp,"%1.2f:%1.2f:%1.2f",r,g,b);
	strcpy (string, temp);
	
	return self;
}

/*
=====================
=
= init
=
=====================
*/

- init
{
	int	i;
	
	prefpanel_i = self;
	window_i = NULL;		// until nib is loaded
	
	for (i=0 ; i<NUMCOLORS ; i++)
		[self getColor: &color[i] fromString: NXGetDefaultValue(APPDEFAULTS, ucolornames[i])];
	
	return self;
}


/*
=====================
=
= appWillTerminate:
=
=====================
*/

- appWillTerminate:sender
{
	int		i;
	char	string[40];
	
	for (i=0 ; i<NUMCOLORS ; i++)
	{
		[self getString: string  fromColor:&color[i]];
		NXWriteDefault(APPDEFAULTS, ucolornames[i], string);
	}
		
	return self;	
}


/*
==============
=
= menuTarget:
=
==============
*/

- menuTarget:sender
{
	int		i;
	
	if (!window_i)
	{
		[NXApp 
			loadNibSection:	"preferences.nib"
			owner:			self
			withNames:		NO
		];
		
		colorwell[0] = backcolor_i;
		colorwell[1] = gridcolor_i;
		colorwell[2] = tilecolor_i;
		colorwell[3] = selectedcolor_i;
		colorwell[4] = pointcolor_i;
		colorwell[5] = onesidedcolor_i;
		colorwell[6] = twosidedcolor_i;
		colorwell[7] = areacolor_i;
		colorwell[8] = thingcolor_i;

		for (i=0 ; i<NUMCOLORS ; i++)
			[colorwell[i] setColor: color[i]];
	}

	[window_i orderFront:self];

	return self;
}

/*
==============
=
= colorChnaged:
=
==============
*/

- colorChanged:sender
{
	int	i;
	id	list, win;
	
// get current colors

	for (i=0 ; i<NUMCOLORS ; i++)
		color[i] = [colorwell[i] color];

// update all windows
	list = [NXApp windowList];
	i = [list count];
	while (--i >= 0)
	{
		win = [list objectAt: i];
		if ([win class] == [MapWindow class])
			[[win mapView] display];
	}
	
	return self;
}

- (NXColor)colorFor: (int)ucolor
{
	return color[ucolor];
}

@end
