#import	"ThingPanel.h"
#import	"ThingStripper.h"

@implementation ThingStripper
//=====================================================================
//
//	Thing Stripper
//
//=====================================================================

//===================================================================
//
//	Load the .nib (if needed) and display the panel
//
//===================================================================
- displayPanel:sender
{
	if (!thingStripPanel_i)
	{
		[NXApp 
			loadNibSection:	"ThingStripper.nib"
			owner:			self
			withNames:		NO
		];
		[thingStripPanel_i	setFrameUsingName:THINGSTRIPNAME];
		[thingStripPanel_i	setDelegate:self];

		thingList_i = [[Storage	alloc]
				initCount:		0
				elementSize:	sizeof(thingstrip_t)
				description:	NULL];
	}
	[thingBrowser_i	reloadColumn:0];
	[thingStripPanel_i	makeKeyAndOrderFront:NULL];
	return self;
}

- windowDidMiniaturize:sender
{
	[sender	setMiniwindowIcon:"DoomEd"];
	[sender	setMiniwindowTitle:"ThingStrip"];
	return self;
}

//
//	Empty list if window gets closed!
//
- windowWillClose:sender
{
	[thingStripPanel_i	saveFrameUsingName:THINGSTRIPNAME];
	[thingList_i	empty];
	return self;
}

//===================================================================
//
//	Do actual Thing stripping from all maps
//
//===================================================================
- doStrippingOneMap:sender
{
	int		k,j;
	int		listMax;
	thingstrip_t	*ts;
	
	listMax = [thingList_i	count];
	if (!listMax)
		return self;
	
	//
	//	Strip all things in list
	//
	for (k = 0;k < numthings;k++)
		for (j = 0;j < listMax; j++)
		{
			ts = [thingList_i	elementAt:j];
			if (ts->value == things[k].type)
				things[k].selected = -1;
		}

	[editworld_i	redrawWindows];
	[doomproject_i	setDirtyMap:TRUE];
	
	return self;
}

//===================================================================
//
//	Do actual Thing stripping from all maps
//
//===================================================================
- doStrippingAllMaps:sender
{
	int		k,j;
	int		listMax;
	thingstrip_t	*ts;
	
	listMax = [thingList_i	count];
	if (!listMax)
		return self;
	
	[editworld_i	closeWorld];
	[doomproject_i	beginOpenAllMaps];
	
	while ([doomproject_i	openNextMap] == YES);
	{
		//
		//	Strip all things in list
		//
		for (k = 0;k < numthings;k++)
			for (j = 0;j < listMax; j++)
			{
				ts = [thingList_i	elementAt:j];
				if (ts->value == things[k].type)
					things[k].selected = -1;
			}

		[doomproject_i	saveDoomEdMapBSP:NULL];
	}
	return self;
}

//===================================================================
//
//	Delete thing from Thing Stripping Panel
//
//===================================================================
- deleteThing:sender
{
	id	matrix;
	int	selRow;
	
	matrix = [thingBrowser_i	matrixInColumn:0];
	selRow = [matrix	selectedRow];
	if (selRow >= 0)
	{
		[matrix	removeRowAt:selRow andFree:YES];
		[thingList_i	removeElementAt:selRow];
	}
	[matrix	sizeToCells];
	[matrix	selectCellAt:-1 :-1];
	[thingBrowser_i	reloadColumn:0];

	return self;
}

//===================================================================
//
//	Add thing in Thing Panel to this list
//
//===================================================================
- addThing:sender
{
	thinglist_t		*t;
	thingstrip_t	ts;

	t =[thingpanel_i	getCurrentThingData];
	if (t == NULL)
	{
		NXBeep();
		return self;
	}
	ts.value = t->value;
	strcpy(ts.desc,t->name);
	[thingList_i	addElement:&ts];
	[thingBrowser_i	reloadColumn:0];
	return self;
}

//===================================================================
//
//	Delegate method called by "thingBrowser_i" when reloadColumn is invoked
//
//===================================================================
- (int)browser:sender  fillMatrix:matrix  inColumn:(int)column
{
	int	max, i;
	id	cell;
	thingstrip_t	*t;
	
	if (column > 0)
		return 0;
		
	max = [thingList_i	count];
	for (i = 0; i < max; i++)
	{
		t = [thingList_i	elementAt:i];
		[matrix	insertRowAt:i];
		cell = [matrix	cellAt:i	:0];
		[cell	setStringValue:t->desc];
		[cell setLeaf: YES];
		[cell setLoaded: YES];
		[cell setEnabled: YES];
	}
	return max;
}

@end
