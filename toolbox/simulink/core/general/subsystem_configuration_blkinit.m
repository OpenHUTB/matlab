



CB = gcb;
status = get_param( CB, 'UserData' );
if isstruct( status ), 
allDataNames = status.allData;
for ndex = 1:length( allDataNames ), 
eval( [ allDataNames{ ndex }, '=evalin(''base'',allDataNames{ndex});' ] );
end 
end 
subsystem_configuration( 'reestablish', CB, 'maskinit' );
subsystem_configuration( 'update', CB );
% Decoded using De-pcode utility v1.2 from file /tmp/tmpvMAx9t.p.
% Please follow local copyright laws when handling this file.

