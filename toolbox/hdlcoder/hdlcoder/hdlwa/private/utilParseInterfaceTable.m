function isReset = utilParseInterfaceTable( mdladvObj, hDI )




hdlwaDriver = hdlwa.hdlwaDriver.getHDLWADriverObj;
targetInterfaceTaskID = utilGetTargetInterfaceTask( hDI );
tableObj = hdlwaDriver.getTaskObj( targetInterfaceTaskID );


tableInputParams = mdladvObj.getInputParameters( tableObj.MAC );
interfaceTable = utilGetInputParameter( tableInputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAInputTargetPlatformInterfaceTable' ) );

tablesetting.Size = interfaceTable.TableSetting.Size;
tablesetting.Data = interfaceTable.TableSetting.Data;
tablesetting.ColHeader = interfaceTable.TableSetting.ColHeader;
tablesetting.ColumnCharacterWidth = interfaceTable.TableSetting.ColumnCharacterWidth;

isReset = false;

try 

hDI.hTurnkey.hTable.parseGUITable( tablesetting );

catch ME

utilUpdateInterfaceTable( mdladvObj, hDI );

tableObj.reset;
isReset = true;

errorMsg = sprintf( [ 'Unable to load last stored Target Interface Table in Task Set Target Interface.\n',  ...
'%s\nPlease reassign target interfaces.' ],  ...
ME.message );
hf = errordlg( errorMsg, 'Error', 'modal' );

set( hf, 'tag', 'Load Target Interface Table error dialog' );
setappdata( hf, 'MException', ME );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpb5rkPC.p.
% Please follow local copyright laws when handling this file.

