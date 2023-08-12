function out = isAutoMappingSupported( hObj )





if isa( hObj, 'Simulink.ConfigSet' ) ||  ...
isa( hObj, 'Simulink.ConfigSetRef' )
hCS = hObj;
else 

hCS = getActiveConfigSet( hObj );
end 

out = false;
tgtHWInfo = codertarget.targethardware.getTargetHardware( hCS );
if ~isempty( tgtHWInfo ) && isprop( tgtHWInfo, 'TaskMap' )
out = tgtHWInfo.TaskMap.useAutoMap;
if ischar( out ) && startsWith( out, 'matlab:' )
out = loc_evaluateFcn( hObj, out );
end 
end 
end 

function out = loc_evaluateFcn( hObj, useAutoMap )
out = false;
try 
out = feval( extractAfter( useAutoMap, 'matlab:' ), hObj );
catch 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpT5gsxC.p.
% Please follow local copyright laws when handling this file.

