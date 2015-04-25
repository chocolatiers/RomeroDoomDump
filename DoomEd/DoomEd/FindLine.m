{\rtf0\ansi{\fonttbl\f1\fmodern Ohlfs;\f0\fswiss Helvetica;}
\paperw13040
\paperh14600
\margl120
\margr120
{\colortbl;\red255\green0\blue3;\red4\green0\blue255;}
\pard\tx533\tx1067\tx1601\tx2135\tx2668\tx3202\tx3736\tx4270\tx4803\tx5337\f1\b0\i0\ulnone\fs24\fc0\cf0 #import	"EditWorld.h"\
#import "FindLine.h"\
\
@implementation FindLine\
\

\gray301\fc1\cf1 //=============================================================\
//\
//	Find Line init\
//\
//=============================================================\

\gray115\fc2\cf2 - init\

\gray0\fc0\cf0 \{\
	window_i = NULL;\
	delSound = [[Sound alloc] initFromSection:"D_EPain"];	return self;\
\}\
\

\gray301\fc1\cf1 //=============================================================\
//\
//	Pop up the window from the menu\
//\
//=============================================================\

\gray115\fc2\cf2 - menuTarget:sender\

\gray0\fc0\cf0 \{\
	if (!window_i)\
	\{\
		[NXApp \
			loadNibSection:	"FindLine.nib"\
			owner:			self\
			withNames:		NO\
		];\
		\
		[status_i	setStringValue:" "];\
		[window_i	setFrameUsingName:PREFNAME];\
	\}\
	[window_i	makeKeyAndOrderFront:self];\
	\
	return self;\
\}\
\

\gray301\fc1\cf1 //=============================================================\
//\
//	Find the line and scroll it to center\
//\
//=============================================================\

\gray115\fc2\cf2 - findLine:sender\

\gray0\fc0\cf0 \{\
	int				linenum;\
	NXRect			r;\
	worldline_t		*l;\
	id				window;\
	\
	linenum = [numfield_i	intValue];\
	if ([fromBSP_i	intValue])\
		linenum = [self	getRealLineNum:linenum];\
	if (linenum < 0)\
	\{\
		[status_i	setStringValue:"No such line!"];\
		return self;\
	\}\
	\
	[editworld_i	selectLine:linenum];\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 	[editworld_i	selectPoint:lines[linenum].p1];\
	[editworld_i	selectPoint:lines[linenum].p2];\

\pard\tx533\tx1067\tx1601\tx2135\tx2668\tx3202\tx3736\tx4270\tx4803\tx5337\fc0\cf0 	\
	l = &lines[linenum];\
	[self	rectFromPoints:&r p1:points[l->p1].pt p2:points[l->p2].pt];\
	window = [editworld_i	getMainWindow];\
	r.origin.x -= MARGIN;\
	r.origin.y -= MARGIN;\
	r.size.width += MARGIN*2;\
	r.size.height += MARGIN*2;\
	[[[window	contentView] docView] scrollRectToVisible:&r];\
	[editworld_i	redrawWindows];\
	[status_i	setStringValue:"Found it!"];\
	\
	return self;\
\}\
\

\gray301\fc1\cf1 //=============================================================\
//\
//	Delete the line\
//\
//=============================================================\

\gray115\fc2\cf2 - deleteLine:sender\

\gray0\fc0\cf0 \{\
	int		linenum;\
	\
	linenum = [numfield_i	intValue];\
	if ([fromBSP_i	intValue])\
		linenum = [self	getRealLineNum:linenum];\
\
	if (linenum < 0)\
	\{\
		[status_i	setStringValue:"No such line!"];\
		return self;\
	\}\
	\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 	[editworld_i	selectLine:linenum];\
	[editworld_i	selectPoint:lines[linenum].p1];\
	[editworld_i	selectPoint:lines[linenum].p2];\
	\

\pard\tx533\tx1067\tx1601\tx2135\tx2668\tx3202\tx3736\tx4270\tx4803\tx5337\fc0\cf0 	lines[linenum].selected = -1;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 	[status_i	setStringValue:"Toasted it!"];\

\pard\tx533\tx1067\tx1601\tx2135\tx2668\tx3202\tx3736\tx4270\tx4803\tx5337\fc0\cf0 	[delSound play];\
	\
	return self;\
\}\
\

\gray301\fc1\cf1 //=============================================================\
//\
//	Skip all the deleted lines in the list and find the correct one\
//\
//=============================================================\

\gray115\fc2\cf2 - (int)getRealLineNum:(int)num\

\gray0\fc0\cf0 \{\
	int	index;\
	int	i;\
	\
	index = 0;\
	for (i = 0;i < numlines;i++)\
	\{\
		if (index == num)\
			return i;\
		if (lines[i].selected != -1)\
			index++;\
	\}\
	\
	return -1;\
\}\
\

\gray301\fc1\cf1 //=============================================================\
//\
//	Wow, this needed to be written.\
//\
//=============================================================\

\gray115\fc2\cf2 - (void)rectFromPoints:(NXRect *)r p1:(NXPoint)p1 p2:(NXPoint)p2\

\gray0\fc0\cf0 \{\
	if (p1.x < p2.x)\
	\{\
		r->origin.x = p1.x;\
		r->size.width = p2.x - p1.x;\
	\}\
	else\
	\{\
		r->origin.x = p2.x;\
		r->size.width = p1.x - p2.x;\
	\}\
	\
	if (p1.y < p2.y)\
	\{\
		r->origin.y = p1.y;\
		r->size.height = p2.y - p1.y;\
	\}\
	else\
	\{\
		r->origin.y = p2.y;\
		r->size.height = p1.y - p2.y;\
	\}\
\}\
\

\gray115\fc2\cf2 - appWillTerminate:sender\

\gray0\fc0\cf0 \{\
	if (window_i)\
		[window_i	saveFrameUsingName:PREFNAME];\
	return self;\
\}\
\
@end\

}
