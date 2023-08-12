function restorePrm( iParamRestoreInfo )







if ( strcmp( iParamRestoreInfo.mPrmName, 'CurrentSystem' ) )
if ( ~bdIsLoaded( iParamRestoreInfo.mOldVal ) )
return ;
end 
end 

set_param( iParamRestoreInfo.mObj,  ...
iParamRestoreInfo.mPrmName,  ...
iParamRestoreInfo.mOldVal );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpZ89W67.p.
% Please follow local copyright laws when handling this file.

