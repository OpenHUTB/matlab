function oParamRestoreInfo = saveAndSetPrm( iObj, iPrmName, iNewVal )






oParamRestoreInfo.mObj = iObj;
oParamRestoreInfo.mPrmName = iPrmName;
oParamRestoreInfo.mOldVal = get_param( iObj, iPrmName );

set_param( iObj, iPrmName, iNewVal );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpJqExor.p.
% Please follow local copyright laws when handling this file.

