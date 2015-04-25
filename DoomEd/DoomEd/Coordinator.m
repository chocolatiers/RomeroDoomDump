
#import "Coordinator.h"
#import "MapWindow.h"
#import "MapView.h"
#import "PreferencePanel.h"
#import "EditWorld.h"
#import	"LinePanel.h"
#import	"SectorEditor.h"
#import	"TextureEdit.h"
#import	"TexturePalette.h"
#import	"ThingPanel.h"
#import	"DoomProject.h"

id	coordinator_i;

BOOL	debugflag = NO;

@implementation Coordinator

- init
{
	coordinator_i = self;
	return self;
}

- toggleDebug: sender
{
	debugflag ^= 1;
	return self;
}

- redraw: sender
{
	int	i;
	id	list, win;
	
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


/*
=============================================================================

					APPLICATION DELEGATE METHODS

=============================================================================
*/

- (BOOL)appAcceptsAnotherFile: sender
{
	if (![editworld_i loaded])
		return YES;
	return NO;
}
	
- (int)app:			sender 
	openFile:		(const char *)filename 
	type:		(const char *)aType
{
	if ([doomproject_i loaded])
		return NO;
	[doomproject_i loadProject: filename];
	return YES;
}


- appDidInit: sender
{
	if (![doomproject_i loaded])
		[doomproject_i loadProject: [prefpanel_i  getProjectPath] ];
	[doomproject_i	setDirtyProject:FALSE];
	[toolPanel_i	setFrameUsingName:TOOLNAME];
	
	if ([prefpanel_i	openUponLaunch:texturePalette] == TRUE)
		[texturePalette_i	menuTarget:NULL];
	if ([prefpanel_i	openUponLaunch:lineInspector] == TRUE)
		[linepanel_i	menuTarget:NULL];
	if ([prefpanel_i	openUponLaunch:lineSpecials] == TRUE)
		[linepanel_i	activateSpecialList:NULL];
	if ([prefpanel_i	openUponLaunch:errorLog] == TRUE)
		[doomproject_i	displayLog:NULL];
	if ([prefpanel_i	openUponLaunch:sectorEditor] == TRUE)
		[sectorEdit_i	menuTarget:NULL];
	if ([prefpanel_i	openUponLaunch:thingPanel] == TRUE)
		[thingpanel_i	menuTarget:NULL];
	if ([prefpanel_i	openUponLaunch:sectorSpecials] == TRUE)
		[sectorEdit_i	activateSpecialList:NULL];
	if ([prefpanel_i	openUponLaunch:textureEditor] == TRUE)
		[textureEdit_i	menuTarget:NULL];
	
	startupSound_i = [[Sound alloc] initFromSection:"D_Dbite"];
	[startupSound_i	play];
	[startupSound_i	free];
	
	return self;
}

- appWillTerminate: sender
{
	[doomproject_i	quit];
	[prefpanel_i appWillTerminate: self];
	[editworld_i appWillTerminate: self];
	
	[sectorEdit_i	saveFrame];
	[textureEdit_i	saveFrame];
	[linepanel_i	saveFrame];
	[texturePalette_i	saveFrame];
	[thingpanel_i	saveFrame];
	[doomproject_i	saveFrame];
	[toolPanel_i	saveFrameUsingName:TOOLNAME];
	
	printf("DoomEd terminated.\n\n");
	return self;
}

@end
