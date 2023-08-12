function isReset = utilParseTargetFrequency( mdladvObj, hDI )




if hDI.isShowGenericTargetFrequencyTask
taskObj = mdladvObj.getTaskObj( 'com.mathworks.HDL.SetGenericTargetFrequency' );
else 
taskObj = mdladvObj.getTaskObj( 'com.mathworks.HDL.SetTargetFrequency' );
end 


tableInputParams = mdladvObj.getInputParameters( taskObj.MAC );
outputFrequency = tableInputParams{ 1 };

isReset = false;

try 
outputFreq = str2double( outputFrequency.Value );

if isnan( outputFreq )
error( message( 'hdlcoder:setTargetFrequency:DCMOutputFrequencyNan', DAStudio.message( 'HDLShared:hdldialog:FPGASystemClockFrequency' ), dcmOutputFrequency.Value ) );
end 

hDI.setTargetFrequency( outputFreq );

catch ME

tableObj.reset;
isReset = true;

errorMsg = sprintf( [ 'Unable to load last stored Target Frequency in Task 1.3.\n',  ...
'%s\nPlease change the value of ''FPGA system clock frequency (MHz)''.' ],  ...
ME.message );
hf = errordlg( errorMsg, 'Error', 'modal' );

set( hf, 'tag', 'Load Target Interface Table error dialog' );
setappdata( hf, 'MException', ME );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpEdJDhz.p.
% Please follow local copyright laws when handling this file.

