
#import "PreferencePanel.h"
#import "MapWindow.h"
#import "DoomProject.h"

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
	"special_c"
};

char		launchTypeName[] = "launchType";
char		projectPathName[] = "projectPath";
char		*openupNames[NUMOPENUP] =
{
	"texturePaletteOpen",
	"lineInspectorOpen",
	"lineSpecialsOpen",
	"errorLogOpen",
	"sectorEditorOpen",
	"thingPanelOpen",
	"sectorSpecialsOpen",
	"textureEditorOpen"
};
int			openupValues[NUMOPENUP];
	
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
		{"special_c","0.5:1:0.5"},
		
//		{"launchType","1"},
		{launchTypeName,"1"},
#if 1
//		{"projectPath","/aardwolf/DoomMaps/project.dpr"},
		{projectPathName,"/aardwolf/DoomMaps/project.dpr"},
#else
		{"projectPath","/RavenDev/maps/project.dpr"},
#endif
		{"texturePaletteOpen",	"1"},
		{"lineInspectorOpen",	"1"},
		{"lineSpecialsOpen",	"1"},
		{"errorLogOpen",		"0"},
		{"sectorEditorOpen",	"1"},
		{"thingPanelOpen",		"0"},
		{"sectorSpecialsOpen",	"0"},
		{"textureEditorOpen",	"0"},
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

- getLaunchThingTypeFrom:(const char *)string
{
	sscanf(string,"%d",&launchThingType);
	return self;
}

- getProjectPathFrom:(const char *)string
{
	sscanf(string,"%s",projectPath);
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
	int		i;
	int		val;
	
	prefpanel_i = self;
	window_i = NULL;		// until nib is loaded
	
	for (i=0 ; i<NUMCOLORS ; i++)
		[self getColor: &color[i]
			fromString: NXGetDefaultValue(APPDEFAULTS, ucolornames[i])];
		
	[self		getLaunchThingTypeFrom:
				NXGetDefaultValue(APPDEFAULTS,launchTypeName)];

	[self		getProjectPathFrom:
				NXGetDefaultValue(APPDEFAULTS,projectPathName)];
	//
	// openup defaults
	//
	for (i = 0;i < NUMOPENUP;i++)
	{
		sscanf(NXGetDefaultValue(APPDEFAULTS,openupNames[i]),"%d",&val);
//		[[openupDefaults_i findCellWithTag:i] setIntValue:val];
		openupValues[i] = val;
	}


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
	
	sprintf(string,"%d",launchThingType);
	NXWriteDefault(APPDEFAULTS,launchTypeName,string);
	
	NXWriteDefault(APPDEFAULTS,projectPathName,projectPath);
	
	for (i = 0;i < NUMOPENUP;i++)
	{
//		sprintf(string,"%d",(int)
//			[[openupDefaults_i findCellWithTag:i] intValue]);
		sprintf(string,"%d",openupValues[i]);
		NXWriteDefault(APPDEFAULTS,openupNames[i],string);
	}
	
	if (window_i)
		[window_i	saveFrameUsingName:PREFNAME];
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
			
		[window_i	setFrameUsingName:PREFNAME];
		
		colorwell[0] = backcolor_i;
		colorwell[1] = gridcolor_i;
		colorwell[2] = tilecolor_i;
		colorwell[3] = selectedcolor_i;
		colorwell[4] = pointcolor_i;
		colorwell[5] = onesidedcolor_i;
		colorwell[6] = twosidedcolor_i;
		colorwell[7] = areacolor_i;
		colorwell[8] = thingcolor_i;
		colorwell[9] = specialcolor_i;

		for (i=0 ; i<NUMCOLORS ; i++)
			[colorwell[i] setColor: color[i]];
			
		for (i = 0;i < NUMOPENUP;i++)
			[[openupDefaults_i	findCellWithTag:i]
				setIntValue:openupValues[i]];
	}

	[launchThingType_i  	setIntValue:launchThingType];
	[projectDefaultPath_i	setStringValue:projectPath];

	[window_i orderFront:self];

	return self;
}

/*
==============
=
= colorChanged:
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

- launchThingTypeChanged:sender
{
	launchThingType = [sender	intValue];
	return self;
}

- (int)getLaunchThingType
{
	return	launchThingType;
}

- projectPathChanged:sender
{
	strcpy(projectPath, [sender	stringValue] );
	return self;
}

- openupChanged:sender
{
	id	cell = [sender selectedCell];
	openupValues[[cell tag]] = [cell intValue];
	return self;
}

- (char *)getProjectPath
{
	return	projectPath;
}

- (BOOL)openUponLaunch:(openup_e)type
{
	if (!openupValues[type])
		return FALSE;
	return TRUE;
}

@end
