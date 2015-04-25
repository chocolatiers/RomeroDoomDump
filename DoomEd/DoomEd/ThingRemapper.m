#import	"EditWorld.h"
#import	"ThingPanel.h"
#import	"ThingRemapper.h"

id	thingRemapper_i;

@implementation ThingRemapper
//===================================================================
//
//	REMAP FLATS IN MAP
//
//===================================================================
- init
{
	thingRemapper_i = self;
	
	remapper_i = [ [ Remapper	alloc ]
				setFrameName:"ThingRemapper"
				setPanelTitle:"Thing Remapper"
				setBrowserTitle:"List of things to be remapped"
				setRemapString:"Thing"
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
	thinglist_t	*t;
	
	t = [thingpanel_i	getCurrentThingData];
	if (t == NULL)
		return NULL;
	return t->name;
}

- (char *)getNewName
{
	thinglist_t	*t;
	
	t = [thingpanel_i	getCurrentThingData];
	if (t == NULL)
		return NULL;
	return t->name;
}

- (int)doRemap:(char *)oldname to:(char *)newname
{
	int	i, thingnum,oldnum,newnum;
	thinglist_t	*t;
	
	t = [thingpanel_i	getThingData:[thingpanel_i	findThing:oldname]];
	oldnum = t->value;
	t = [thingpanel_i	getThingData:[thingpanel_i	findThing:newname]];
	newnum = t->value;
	thingnum = 0;
	
	for (i = 0;i < numthings; i++)
	{
		if (things[i].type == oldnum)
		{
			things[i].type = newnum;
			thingnum++;
		}
	}
	
	return thingnum;
}

- finishUp
{
	[editworld_i	redrawWindows];
	return self;
}

@end
