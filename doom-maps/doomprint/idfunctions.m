#import "idfunctions.h"

/*
============
=
= BoxFromRect
=
============
*/

void BoxFromRect (box_t *box, NXRect *rect)
{
	box->left = rect->origin.x;
	box->right = box->left + rect->size.width;
	box->bottom= rect->origin.y;
	box->top = box->bottom + rect->size.height;	
}


/*
============
=
= BoxFromPoints
=
============
*/

void BoxFromPoints (box_t *box, NXPoint *p1, NXPoint *p2)
{
	if (p1->x < p2->x)
	{
		box->left = p1->x;
		box->right = p2->x;
	}
	else
	{
		box->right = p1->x;
		box->left = p2->x;
	}
	if (p1->y < p2->y)
	{
		box->bottom = p1->y;
		box->top = p2->y;
	}
	else
	{
		box->top = p1->y;
		box->bottom = p2->y;
	}
}


/*
================
=
= IDRectFromPoints
=
= Makes the rectangle just touch the two points
=
================
*/

void IDRectFromPoints(NXRect *rect, NXPoint const *p1, NXPoint const *p2 )
{
// return a rectangle that encloses the two points
	if (p1->x < p2->x)
	{
		rect->origin.x = p1->x;
		rect->size.width = p2->x - p1->x + 1;
	}
	else
	{
		rect->origin.x = p2->x;
		rect->size.width = p1->x - p2->x + 1;
	}
	
	if (p1->y < p2->y)
	{
		rect->origin.y = p1->y;
		rect->size.height = p2->y - p1->y + 1;
	}
	else
	{
		rect->origin.y = p2->y;
		rect->size.height = p1->y - p2->y + 1;
	}
}


/*
==================
=
= IDEnclosePoint
=
= Make the rect enclose the point if it doesn't allready
=
==================
*/

void IDEnclosePoint (NXRect *rect, NXPoint const *point)
{
	float	right, top;
	
	right = rect->origin.x + rect->size.width - 1;
	top = rect->origin.y + rect->size.height - 1;
	
	if (point->x < rect->origin.x)
		rect->origin.x = point->x;
	if (point->y < rect->origin.y)
		rect->origin.y = point->y;		
	if (point->x > right)
		right = point->x;
	if (point->y > top)
		top = point->y;
		
	rect->size.width = right - rect->origin.x + 1;
	rect->size.height = top - rect->origin.y + 1;
}



/*
===================
=
= IdException
=
===================
*/

void IdException (char const *format, ...)
{
	char		msg[1025];
	va_list 	args;
	
	va_start(args, format);
	vsprintf(msg, format, args);
	va_end(args);
	strcat (msg,"\n");
	
	NX_RAISE (NX_APPBASE, msg, 0);
}


long LongSwap (long x)
{
	return NXSwapHostLongToLittle(x);
}