function status = registerAdapter( adapterClassName )



R36
adapterClassName( 1, 1 )string
end 

try 
adapter = eval( adapterClassName );%#ok<NASGU> Check to see if it can be instantiated prior to continuing

status = sl.data.adapter.AdapterManagerV2.registerMatlabAdapter( adapterClassName );
catch ex
status = false;
warning( ex.identifier, '%s', ex.message );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmprO6XlS.p.
% Please follow local copyright laws when handling this file.

