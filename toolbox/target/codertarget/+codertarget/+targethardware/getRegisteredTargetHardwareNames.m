function names = getRegisteredTargetHardwareNames( varargin )




targetHardwares = codertarget.targethardware.getRegisteredTargetHardware( varargin{ : } );
numTargets = length( targetHardwares );
names = cell( 1, numTargets );
for i = 1:length( targetHardwares )
names{ i } = targetHardwares( i ).DisplayName;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpT0KAwc.p.
% Please follow local copyright laws when handling this file.

