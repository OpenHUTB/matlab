function utilReloadInterfaceTable( mdladvObj, hDI )











if hDI.isBoardEmpty
return ;
end 

system = mdladvObj.System;
modelName = bdroot( system );


msg = {  };

try 

msg1 = hDI.loadInterfaceTable( system );
msg = [ msg, msg1 ];
catch ME
if strcmp( ME.identifier, 'hdlcommon:workflow:TestPointNamesNotUnique' )

headerStr = message( 'hdlcommon:workflow:TestPointUniquificationDialog' ).getString;
okStr = message( 'hdlcommon:workflow:OK' ).getString;
cancelStr = message( 'hdlcommon:workflow:Cancel' ).getString;
questionStr = message( 'hdlcommon:workflow:TestPointNamesUniquification', ME.message, okStr ).getString;


userChoice = questdlg( questionStr, headerStr, okStr, cancelStr, okStr );

switch userChoice
case okStr

uniquifyTestPointNames( system, true );

utilReloadInterfaceTable( mdladvObj, hDI );
case { cancelStr, '' }
rethrow( ME );
otherwise 
rethrow( ME );
end 
else 
rethrow( ME );
end 
end 


utilUpdateInterfaceTable( mdladvObj, hDI );






if ~isempty( msg )

hDI.emitLoadingErrorMsg( modelName, msg );


slmsgviewer.Instance(  ).show(  );
slmsgviewer.selectTab( modelName );



ME = MException( message( 'hdlcommon:workflow:ApplySettingErrorFromModel' ) );
hf = warndlg( ME.message, 'Warning', 'modal' );


set( hf, 'tag', 'HDL Workflow Advisor error dialog' );
setappdata( hf, 'MException', ME );


uiwait( hf );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpfIofQQ.p.
% Please follow local copyright laws when handling this file.

