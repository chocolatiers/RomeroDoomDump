#import <appkit/appkit.h>

void		StartPath (int path);
void		AddLine (int path, float x1, float y1, float x2, float y2);
void		FinishPath (int path);
BOOL	LineInRect (NXPoint *p1, NXPoint *p2, NXRect *r);
