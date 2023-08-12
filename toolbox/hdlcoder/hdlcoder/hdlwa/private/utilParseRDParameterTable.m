function isReset = utilParseRDParameterTable( mdladvObj, hDI )




hdlwaDriver = hdlwa.hdlwaDriver.getHDLWADriverObj;
RDTaskID = 'com.mathworks.HDL.SetTargetReferenceDesign';
tableObj = hdlwaDriver.getTaskObj( RDTaskID );


tableInputParams = mdladvObj.getInputParameters( tableObj.MAC );
rdParamTable = utilGetInputParameter( tableInputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAInputRDParameterTable' ) );

tablesetting.Size = rdParamTable.TableSetting.Size;
tablesetting.Data = rdParamTable.TableSetting.Data;
tablesetting.ColHeader = rdParamTable.TableSetting.ColHeader;
tablesetting.ColumnCharacterWidth = rdParamTable.TableSetting.ColumnCharacterWidth;

isReset = false;

try 

hRD = hDI.hIP.getReferenceDesignPlugin;
if ~isempty( hRD )
hRD.parseParameterGUITable( tablesetting )
end 

catch ME

hdlwa.utilUpdateRDParameterTable( mdladvObj, hDI );

tableObj.reset;
isReset = true;

errorMsg = sprintf( [ 'Unable to load last stored Reference design parameter table in Task Set Target Reference Design.\n',  ...
'%s\nPlease reassign reference design parameter.' ],  ...
ME.message );
hf = errordlg( errorMsg, 'Error', 'modal' );

set( hf, 'tag', 'Load Reference design parameter table error dialog' );
setappdata( hf, 'MException', ME );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHlNt23.p.
% Please follow local copyright laws when handling this file.

