function out = getNumberOfCores( hCS )




if codertarget.data.isParameterInitialized( hCS, 'Processor.NumberOfCores' )
numCores = codertarget.data.getParameterValue( hCS, 'Processor.NumberOfCores' );
if ischar( numCores ) || isstring( numCores )
out = str2double( numCores );
else 
out = numCores;
end 
else 
hwObj = codertarget.targethardware.getTargetHardware( hCS );
out = hwObj.NumOfCores;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpqtzPCy.p.
% Please follow local copyright laws when handling this file.

