function exists = globalDataItemExists( symbolName, dataLocation )



















assert( ischar( dataLocation ) );
assert( ~isempty( dataLocation ) );
assert( ischar( symbolName ) );
if isempty( symbolName )
exists = false;
else 
if strcmp( dataLocation, 'base' )
exists = evalin( 'base', [ 'exist(''', symbolName, ''',''var'');' ] );
else 


dd = Simulink.dd.open( dataLocation );
exists = dd.entryExists( [ 'Global.', symbolName ], true );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJrtLdX.p.
% Please follow local copyright laws when handling this file.

