function hVal = pmsl_getdoublehandle( hBlk )














hVal =  - 1;

if isa( hBlk, 'double' )
hVal = hBlk;
elseif isa( hBlk, 'Simulink.Block' )
hVal = get( hBlk, 'Handle' );
elseif isa( hBlk, 'char' ) || isa( hBlk, 'string' )
hVal = get_param( hBlk, 'Handle' );
else 
error( 'Unrecognized class' );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpcJVtY3.p.
% Please follow local copyright laws when handling this file.

