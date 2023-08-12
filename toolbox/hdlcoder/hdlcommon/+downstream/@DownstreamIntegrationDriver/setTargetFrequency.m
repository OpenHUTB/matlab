function logTxt = setTargetFrequency( obj, clockFreq )

logTxt = '';

if obj.isFILWorkflow
if isempty( obj.hFilBuildInfo )
return ;

end 
strFreq = sprintf( '%0.4fMHz', clockFreq );
obj.hFilBuildInfo.FPGASystemClockFrequency = strFreq;
else 






hClockModule = obj.getClockModule;


if isempty( hClockModule )
if isempty( obj.hTurnkey.hBoard )
error( message( 'hdlcoder:workflow:BoardNotExist' ) );
end 
if isempty( obj.hTurnkey.hBoard.hClockModule )
error( message( 'hdlcoder:workflow:BoardClockModuleNotExist' ) );
end 
end 

if obj.isIPCoreGen || obj.isGenericWorkflow
hClockModule.setClockModuleOutputFreq( clockFreq );
else 
if obj.cmdDisplay
hClockModule.setClockModuleOutputFreq( obj, clockFreq );
else 
logTxt = evalc( 'hClockModule.setClockModuleOutputFreq( obj, clockFreq )' );
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp_r5XrU.p.
% Please follow local copyright laws when handling this file.

