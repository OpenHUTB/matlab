function names = getRegisteredSimulinkTargetHardwareNames(  )





names = {  };
info = codertarget.targethardware.getRegisteredTargetHardware;
for i = 1:numel( info )
if isequal( info( i ).TargetType, 1 )
names{ end  + 1 } = info( i ).Name;%#ok<AGROW>
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmplmyIRR.p.
% Please follow local copyright laws when handling this file.

