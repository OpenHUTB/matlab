function isReset = utilParseMapping( mdladvObj, hDI )




hdlwaDriver = hdlwa.hdlwaDriver.getHDLWADriverObj;
taskObj = hdlwaDriver.getTaskObj( 'com.mathworks.HDL.RunMapping' );


inputParams = mdladvObj.getInputParameters( taskObj.MAC );
SkipPreRouteTimingAnalysis = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAInputSkipTimingAnalysis' ) );

isReset = false;

try 
if ~isequal( SkipPreRouteTimingAnalysis.Value, hDI.SkipPreRouteTimingAnalysis )
hDI.SkipPreRouteTimingAnalysis = SkipPreRouteTimingAnalysis.Value;
end 

catch ME

taskObj.reset;
isReset = true;

errorMsg = sprintf( [ 'Error occurred in Task 4.2 when loading Restore Point.\n',  ...
'The error message is:\n%s\n' ],  ...
ME.message );
hf = errordlg( errorMsg, 'Error', 'modal' );

set( hf, 'tag', 'load Pre Route Timing error dialog' );
setappdata( hf, 'MException', ME );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpmDqKBb.p.
% Please follow local copyright laws when handling this file.

