
#import <appkit/appkit.h>

@interface FindLine:Object
{
	id	window_i;
	id	status_i;
	id	numfield_i;
	id	delSound;
	id	fromBSP_i;
}

#define MARGIN		64			// margin from window edge
#define	PREFNAME	"FindLinePanel"

- (int)getRealLineNum:(int)num;
- findLine:sender;
- deleteLine:sender;
- menuTarget:sender;
- (void)rectFromPoints:(NXRect *)r p1:(NXPoint)p1 p2:(NXPoint)p2;

@end
