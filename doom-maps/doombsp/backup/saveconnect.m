{\rtf0\ansi{\fonttbl\f0\fmodern Ohlfs;}
\paperw13040
\paperh14060
\margl120
\margr120
{\colortbl;\red0\green74\blue29;\red26\green5\blue1;\red0\green29\blue142;\red0\green17\blue153;\red0\green0\blue0;}
\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\f0\b0\i0\ulnone\fs24\fc0\cf0 // saveconnect.m\
\
#import "doombsp.h"\
\

\gray183\fc1\cf1 typedef struct\
\{\
	int		x,y;\
\} bpoint_t;\
\
typedef struct\
\{\
	int		xl, xh, yl, yh;\
\} bbox_t;\
\
typedef struct\
\{\
	bpoint_t	p1, p2;\
	bbox_t		bounds;\
\} bline_t;\

\gray0\fc0\cf0 \

\gray183\fc1\cf1 typedef struct\
\{\
	int			numpoints;\
	bpoint_t	*points;\
\} bchain_t;\
\
typedef struct\
\{\
	int		x,y;\
	int		dx,dy;\
\} bdivline_t;\

\gray0\fc0\cf0 \
\

\gray43\fc2\cf2 // [numsec][numsec] array\
byte		*connections;\
\
int			numblines;\
bline_t	*blines;\
\
int			numsectors;\
bbox_t		*secboxes;\

\gray0\fc0\cf0 \
int			numbchains;\
bchain_t	*bchains;\
\
void ClearBBox (bbox_t *box)\
\{\
	box->xl = box->yl = MAXINT;\
	box->xh = box->yh = MININT;\
\}\
\
void AddToBBox (bbox_t *box, int x, int y)\
\{\
	if (x < box->xl)\
		box->xl = x;\
	if (x > box->xh)\
		box->xh = x;\
	if (y < box->yl)\
		box->yl = y;\
	if (y > box->yh)\
		box->yh = y;\
\}\
\
\
/*\
==================\
=\
= PointOnSide\
=\
= Returns side 0 (front), 1 (back), or -1 (colinear)\
==================\
*/\
\
int	BPointOnSide (int x, int y, bdivline_t *l)\
\{\
	int		dx,dy;\
	int		left, right;\
	\
	if (!l->dx)\
	\{\
		if (x < l->x)\
			return l->dy > 0;\
		return l->dy < 0;\
	\}\
	if (!l->dy)\
	\{\
		if (y < l->y)\
			return l->dx < 0;\
		return l->dx > 0;\
	\}\
	\
	\
	dx = x - l->x;\
	dy = y - l->y;\
	\
	left = l->dy * dx;\
	right = dy * l->dx;\
	\
	if (right < left)\
		return 0;		// front side\
	return 1;			// back side\
\}\
\
\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 void DrawBBox (bbox_t *box)\
\{\
	PSmoveto (box->xl,box->yl);\
	PSlineto (box->xh,box->yl);\
	PSlineto (box->xh,box->yh);\
	PSlineto (box->xl,box->yh);\
	PSlineto (box->xl,box->yl);\
	PSstroke ();\
	NXPing ();\
\}\
\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 void DrawDivline (bdivline_t *li)\
\{\
	PSmoveto (li->x,li->y);\
	PSrlineto (li->dx,li->dy);\
	PSstroke ();\
	NXPing ();\
\}\
\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 \
bdivline_t	ends[2], sides[2];\
\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fs32\gray128\fc3\cf3 /*\
====================\
=\
= 
\fs24\gray105\fc4\cf4 DoesChainBlock
\fs32\gray128\fc3\cf3 \
=\
====================\
*/\

\fs24\gray0\fc0\cf0 \

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 boolean DoesChainBlock (bchain_t *chain)\
\{\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 /*\
\
if a solid line can be walked from one side to the other without going out\
an end, the path is blocked\
\
find a line with one point off an end and the other point inside or off other\
end\
\
solidchain\
\
startside = -1;		// not started yet\
startp = -1;\
for (p=0 ; ; p = (p+1)%nump)\
\{\
	if (startp == -1 && p =\
	if (p==startp\
	\
// find side for p\
\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 	if (side == middle)\
		continue;			// may still cross over\
\
	if (side is off)\
		startside = -1;	// break chain\
		break chain\
		continue\
		\
	if (startside == -1)\
		start chain\
		continue\
				\
	if (side == startside)\
		continue;			// haven't crossed in yet\
		\
// opposite of startside\
	if (tracing)\
		goto blocked;		// totally crossed area\
		\
	startside = side;	// starting a chain\
\}\
\
follow chain until p[n-1] is a side and p[n] is middle or other side\
if other side, its blocked\
\
	\
*/\
	return false;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 \}\
\

\fs32\gray128\fc3\cf3 /*\
====================\
=\
= 
\fs36 BuildConnections
\fs32 \
=\
====================\
*/\

\fs24\gray0\fc0\cf0 \
enum \{si_north, si_east, si_south, si_west\};\
\
void BuildConnections (void)\
\{\
	int			blockcount, passcount;\
	int			i,j, k, s, bn;\
	int			x,y;\
	bbox_t		*bbox[2];\
	int			walls[4];\
	bpoint_t	points[2][2];\
		\
// look for obscured sectors\
	blockcount = passcount = 0;\
	bbox[0] = secboxes;\
	for (i=0 ; i<
\fc5\cf5 numsectors
\fc0\cf0 -1 ; i++, bbox[0]++)\
	\{\
		bbox[1] = bbox[0] + 1;\
		if (bbox[0]->xh - bbox[0]->xl < 64 || bbox[0]->yh - bbox[0]->yl < 64)\
		\{	// don't bother with small sectors (stairs, doorways, etc)\
			passcount += (numsectors-i);\
			continue;\
		\}\
\
		for (j=i+1 ; j<
\fc5\cf5 numsectors
\fc0\cf0  ; j++, bbox[1]++)\
		\{\
			if (bbox[1]->xh - bbox[1]->xl < 64 || bbox[1]->yh - bbox[1]->yl < 64)\
			\{	// don't bother with small sectors (stairs, doorways, etc)\
				passcount++;\
				continue;\
			\}\
			if (bbox[1]->xl <= bbox[0]->xh && bbox[1]->xh >= bbox[0]->xl &&\
			bbox[1]->yl <= bbox[0]->yh && bbox[1]->yh >= bbox[0]->yl)\
			\{	// touching sectors are never blocked\
				passcount++;\
				continue;\
			\}\
\
//\
// calculate the swept area between the sectors\
//\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			for (bn=0 ; bn<2 ; bn++)\
			\{\
				memset (walls,0,sizeof(walls));\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 				if (bbox[bn]->xl <= bbox[!bn]->xl)\
					walls[si_west] = 1;\
				if (bbox[bn]->xh >= bbox[!bn]->xh)\
					walls[si_east] = 1;\
				if (bbox[bn]->yl <= bbox[!bn]->yl)\
					walls[si_south] = 1;\
				if (bbox[bn]->yh >= bbox[!bn]->yh)\
					walls[si_north] = 1;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 \
				for (s=0 ; s<5 ; s++)\
				\{\
					switch (s&3)\
					\{\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 					case si_north:\
						x = bbox[bn]->xl;\
						y = bbox[bn]->yh;\
						break;\
					case si_east:\
						x = bbox[bn]->xh;\
						y = bbox[bn]->yh;\
						break;\
					case si_south:\
						x = bbox[bn]->xh;\
						y = bbox[bn]->yl;\
						break;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 					case si_west:\
						x = bbox[bn]->xl;\
						y = bbox[bn]->yl;\
						break;
\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			\
					\}\
					if (!walls[(s-1)&3] && walls[s&3])\
					\{\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 						points[bn][0].x = x;\
						points[bn][0].y = y;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 					\}\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 					if (walls[(s-1)&3] && !walls[s&3])\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 					\{\
						points[bn][1].x = x;\
						points[bn][1].y = y;\
					\}\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 				\}\
				\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 				ends[bn].x = points[bn][0].x;\
				ends[bn].y = points[bn][0].y;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 				ends[bn].dx = points[bn][1].x - points[bn][0].x;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 				ends[bn].dy = points[bn][1].y - points[bn][0].y;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			\}\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 \

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			sides[0].x = points[0][0].x;\
			sides[0].y = points[0][0].y;\
			sides[0].dx = points[1][1].x - points[0][0].x;\
			sides[0].dy = points[1][1].y - points[0][0].y;\
			\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			sides[1].x = points[0][1].x;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			sides[1].y = points[0][1].y;\
			sides[1].dx = points[1][0].x - points[0][1].x;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			sides[1].dy = points[1][0].y - points[0][1].y;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 		\
			EraseWindow ();	\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			DrawBBox (bbox[0]);\
			DrawBBox (bbox[1]);\
			DrawDivline (&ends[0]);\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			DrawDivline (&ends[1]);\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			DrawDivline (&sides[0]);\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			DrawDivline (&sides[1]);\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 //		\
// look for a line change that covers the swept area\
//\
			for (k=0 ; k<numbchains ; k++)\
			\{\
				if (!DoesChainBlock (&bchains[k]))\
					continue;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 				blockcount++;\
				goto blocked;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			\}\
\
// nothing definately blocked the path\
			passcount++;				\
blocked:;\
		\}\
	\}\
\}\
\
\

\fs32\gray128\fc3\cf3 /*\
====================\
=\
= ProcessConnections\
=\
====================\
*/\

\fs24\gray0\fc0\cf0 \
void ProcessConnections (void)\
\{\
	int					i, s, wlcount, count;\
	bbox_t				*secbox;\
	id					lines;\
	worldline_t		*wl;\
	mapvertex_t		*vt;\
	maplinedef_t		*p;\
	mapsidedef_t		*sd;\
	bline_t			bline;\
	int					sec;\
		\
	numsectors = [secstore_i count];\
	wlcount = [linestore_i count];\
\
	connections = malloc (numsectors*numsectors);\
	memset (connections, 0, numsectors*numsectors);\
	\
	secboxes = secbox = malloc (numsectors*sizeof(bbox_t));\
	for (i=0 ; i<numsectors ; i++, secbox++)\
		ClearBBox (secbox);\
\
//			\
// calculate bounding boxes for all sectors\
//\
	count = [ldefstore_i count];\
	p = [ldefstore_i elementAt:0];\
	vt = [mapvertexstore_i elementAt:0];\
	for (i=0 ; i<count ; i++, p++)\
	\{\
		for (s=0 ; s<1 ; s++)\
		\{\
			if (p->sidenum[s] == -1)\
				continue;			// no back side\
			// add both points to sector bounding box\
			sd = (mapsidedef_t *)[sdefstore_i elementAt: p->sidenum[s]];\
			sec = sd->sector;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			AddToBBox (&secboxes[sec], vt[p->v1].x, vt[p->v1].y);\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 			AddToBBox (&secboxes[sec], vt[p->v2].x, vt[p->v2].y);\
		\}\
	\}\
\
//	\
// make a list of only the solid lines\
//\
	lines = [[Storage alloc]\
					initCount:		0\
					elementSize:	4\
					description:	NULL];\
	\
	wl = [linestore_i elementAt: 0];\
	for ( i=0 ; i<wlcount ; wl++,i++)\
	\{\
		if (wl->flags & ML_TWOSIDED)\
			continue;			// don't add two sided lines\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 		bline.p1.x = wl->p1.x;\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 		bline.p1.y = wl->p1.y;\
		bline.p2.x = wl->p2.x;\
		bline.p2.y = wl->p2.y;\
		ClearBBox (&bline.bounds);\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 		AddToBBox (&bline.bounds, bline.p1.x, bline.p1.y);\

\pard\tx520\tx1060\tx1600\tx2120\tx2660\tx3200\tx3720\tx4260\tx4800\tx5320\fc0\cf0 		AddToBBox (&bline.bounds, bline.p2.x, bline.p2.y);\
		[lines addElement: &bline];\
	\}\
	blines = [lines elementAt: 0];\
	numblines = [lines count];\
	\
//\
// build connection list\
//\
	BuildConnections ();\
\}\
\
\

}
