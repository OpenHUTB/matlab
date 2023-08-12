function out = isConnectedIOSupported( hObj )




if isa( hObj, 'Simulink.ConfigSet' ) ||  ...
isa( hObj, 'Simulink.ConfigSetRef' )
hCS = hObj;
else 

hCS = getActiveConfigSet( hObj );
end 

out = false;
targetHardwareInfo = codertarget.targethardware.getTargetHardware( hCS );
if ~isempty( targetHardwareInfo ) && isprop( targetHardwareInfo, 'SupportsConnectedIO' )
out = targetHardwareInfo.SupportsConnectedIO;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpmSy4AR.p.
% Please follow local copyright laws when handling this file.

