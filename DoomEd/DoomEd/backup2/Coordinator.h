
#import <appkit/appkit.h>

extern	id	coordinator_i;

extern	BOOL	debugflag;

@interface Coordinator:Object
{
	SNDSoundStruct	*popstruct,*dripstruct;
}

- toggleDebug: sender;
- redraw: sender;
- playPop;
- playDrip;

@end
