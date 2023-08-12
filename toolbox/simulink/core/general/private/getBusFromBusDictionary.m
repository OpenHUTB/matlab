

























function [ result, subBusNames ] = getBusFromBusDictionary( busName, reportWarning )
busDict = Simulink.BusDictionary.getInstance(  );
potentialRegisteredBusType = busDict.getRegisteredBusType( busName );


if ~isempty( potentialRegisteredBusType )
result = potentialRegisteredBusType;


if reportWarning
cDef = meta.class.fromName( busName );
if numel( cDef ) ~= 0
warningid = 'Simulink:Bus:BusRegisterShadowClassBasedBus';
MSLDiagnostic( warningid, busName ).reportAsWarning;
end 
end 
else 

result = constructSLBusUsingMLClass( busName );
end 


subBusNames = {  };
if isempty( result )
return ;
end 

for idx = 1:length( result.Elements )
curElemDT = result.Elements( idx ).DataType;

if startsWith( curElemDT, 'Bus:' )

curElemDT = erase( curElemDT, 'Bus:' );
curElemDT = strtrim( curElemDT );
subBusNames = [ subBusNames;curElemDT ];
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphyzjPM.p.
% Please follow local copyright laws when handling this file.

