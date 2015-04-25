#import <appkit/appkit.h>
#import "cmdlib.h"

typedef struct
{
	float	left, bottom, right, top;
} box_t;

void BoxFromRect (box_t *box, NXRect *rect);
void BoxFromPoints (box_t *box, NXPoint *p1, NXPoint *p2);

void IDRectFromPoints( NXRect *rect, NXPoint const *p1, NXPoint const *p2 );
void IDEnclosePoint (NXRect *rect, NXPoint const *point);

void IdException (char const *format, ...);
