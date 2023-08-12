function out = isTaskMappingSupported( hObj )





if isa( hObj, 'Simulink.ConfigSet' ) ||  ...
isa( hObj, 'Simulink.ConfigSetRef' )
hCS = hObj;
else 

hCS = getActiveConfigSet( hObj );
end 

out = false;
targetHardwareInfo = codertarget.targethardware.getTargetHardware( hCS );
if ~isempty( targetHardwareInfo ) && isprop( targetHardwareInfo, 'TaskMap' )
out = targetHardwareInfo.TaskMap.isSupported;
if ischar( out ) && startsWith( out, 'matlab:' )
out = loc_evaluateFcn( hObj, out );
end 
end 
end 

function out = loc_evaluateFcn( hObj, isSupported )
out = false;
try 
out = feval( extractAfter( isSupported, 'matlab:' ), hObj );
catch 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp01dkiu.p.
% Please follow local copyright laws when handling this file.

