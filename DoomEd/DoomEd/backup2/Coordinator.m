
#import "Coordinator.h"
#import "MapWindow.h"
#import "MapView.h"
#import "PreferencePanel.h"
#import "EditWorld.h"

id	coordinator_i;

BOOL	debugflag = NO;

@implementation Coordinator

- init
{
	coordinator_i = self;
//	popSound = [[Sound	alloc]
//				initFromSection:"Pop.snd"];
//	dripSound = [[Sound	alloc]
//				initFromSection:"Drip.snd"];
	SNDReadSoundfile("Pop.snd",&popstruct);	
	SNDReadSoundfile("Drip.snd",&dripstruct);
	return self;
}

- playPop
{
//	[popSound	play];
	SNDStartPlaying(popstruct,0,5,0,0,0);
	return self;
}

- playDrip
{
//	[dripSound	play];
	SNDStartPlaying(dripstruct,1,5,0,0,0);
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
		[doomproject_i loadProject: "/aardwolf/DoomMaps/project.dpr"];
	return self;
}

- appWillTerminate: sender
{
	[prefpanel_i appWillTerminate: self];
	[editworld_i appWillTerminate: self];
	
	return self;
}

@end
