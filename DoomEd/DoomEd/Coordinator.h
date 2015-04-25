
#import <appkit/appkit.h>

extern	id	coordinator_i;

extern	BOOL	debugflag;

#define	TOOLNAME	"ToolPanel"

@interface Coordinator:Object
{
	id	toolPanel_i;
	id	infoPanel_i;
	id	startupSound_i;
}

- toggleDebug: sender;
- redraw: sender;
@end
