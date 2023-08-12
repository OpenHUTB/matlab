function varExists = updateInDDSetIfExist( ddSet, varName, varValue )

















varExists = 0;
for i = 1:length( ddSet )
libDDName = ddSet{ i };
ddConn = Simulink.dd.open( libDDName );
if ( ddConn.isOpen )
try 
if ddConn.entryExists( [ 'Global.', varName ], true )
varExists = 1;
ddConn.assignin( varName, varValue );
end 
catch E
if isequal( E.identifier, 'SLDD:sldd:InvalidEntryName' )
varExists = 0;
else 
rethrow( E );
end 
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpRVlTrC.p.
% Please follow local copyright laws when handling this file.

