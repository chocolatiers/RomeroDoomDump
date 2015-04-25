/* ./sym/wraps.c generated from wraps.psw
   by unix pswrap V1.009  Wed Apr 19 17:50:24 PDT 1989
 */

#include <dpsclient/dpsfriends.h>
#include <string.h>

#line 1 "wraps.psw"
#import <appkit/appkit.h>
#line 11 "./sym/wraps.c"
void PSWHitPath(const float HPts[], int Tot_HPts, const char HOps[], int Tot_HOps, const float Pts[], int Tot_Pts, const char Ops[], int Tot_Ops, int *Hit)
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjGeneric obj1;
    DPSBinObjGeneric obj2;
    DPSBinObjGeneric obj3;
    DPSBinObjGeneric obj4;
    DPSBinObjGeneric obj5;
    DPSBinObjGeneric obj6;
    DPSBinObjGeneric obj7;
    DPSBinObjGeneric obj8;
    DPSBinObjGeneric obj9;
    DPSBinObjGeneric obj10;
    DPSBinObjGeneric obj11;
    DPSBinObjGeneric obj12;
    } _dpsQ;
  static const _dpsQ _dpsStat = {
    DPS_DEF_TOKENTYPE, 9, 108,
    {DPS_LITERAL|DPS_ARRAY, 0, 2, 88},
    {DPS_LITERAL|DPS_ARRAY, 0, 2, 72},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 312},	/* inustroke */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 119},	/* printobject */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_LITERAL|DPS_INT, 0, 0, 1},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 119},	/* printobject */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 70},	/* flush */
    {DPS_LITERAL|DPS_STRING, 0, 0, 104},	/* param[var]: Pts */
    {DPS_LITERAL|DPS_STRING, 0, 0, 104},	/* param Ops */
    {DPS_LITERAL|DPS_STRING, 0, 0, 104},	/* param[var]: HPts */
    {DPS_LITERAL|DPS_STRING, 0, 0, 104},	/* param HOps */
    }; /* _dpsQ */
  _dpsQ _dpsF;	/* local copy  */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  char pad[3];
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  register int _dps_offset = 104;
  DPSResultsRec _dpsR[1];
  static const DPSResultsRec _dpsRstat[] = {
    { dps_tBoolean, -1 },
    };
    _dpsR[0] = _dpsRstat[0];
    _dpsR[0].value = (char *)Hit;

  _dpsF = _dpsStat;	/* assign automatic variable */

  _dpsP[11].length = (Tot_HPts * sizeof(float)) + 4;
  _dpsP[12].length = Tot_HOps;
  _dpsP[9].length = (Tot_Pts * sizeof(float)) + 4;
  _dpsP[10].length = Tot_Ops;
  _dpsP[12].val.stringVal = _dps_offset;
  _dps_offset += (Tot_HOps + 3) & ~3;
  _dpsP[11].val.stringVal = _dps_offset;
  _dps_offset += (Tot_HPts * sizeof(float)) + 4;
  _dpsP[10].val.stringVal = _dps_offset;
  _dps_offset += (Tot_Ops + 3) & ~3;
  _dpsP[9].val.stringVal = _dps_offset;
  _dps_offset += (Tot_Pts * sizeof(float)) + 4;

  _dpsF.nBytes = _dps_offset+4;
  DPSSetResultTable(_dpsCurCtxt, _dpsR, 1);
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,108);
  DPSWriteStringChars(_dpsCurCtxt, (char *)HOps, Tot_HOps);
  DPSWriteStringChars(_dpsCurCtxt, (char *)pad, ~(Tot_HOps + 3) & 3);
  DPSWriteNumString(_dpsCurCtxt, dps_tFloat, HPts, Tot_HPts, 0);
  DPSWriteStringChars(_dpsCurCtxt, (char *)Ops, Tot_Ops);
  DPSWriteStringChars(_dpsCurCtxt, (char *)pad, ~(Tot_Ops + 3) & 3);
  DPSWriteNumString(_dpsCurCtxt, dps_tFloat, Pts, Tot_Pts, 0);
  DPSAwaitReturnValues(_dpsCurCtxt);
  if (0) *pad = 0;    /* quiets compiler warnings */
}
#line 15 "wraps.psw"


