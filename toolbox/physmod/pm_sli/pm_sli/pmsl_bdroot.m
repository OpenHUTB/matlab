function rootSys = pmsl_bdroot( hdl )






try 

rootSys = bdroot( hdl );

catch exception %#ok

regexpPattern = '^(?<rootName>[^/]+)/.+';
match = regexp( getfullname( hdl ), regexpPattern, 'names' );
rootSys = match.rootName;

end 

rootSys = get_param( rootSys, 'Handle' );



% Decoded using De-pcode utility v1.2 from file /tmp/tmp3fhJ6J.p.
% Please follow local copyright laws when handling this file.

