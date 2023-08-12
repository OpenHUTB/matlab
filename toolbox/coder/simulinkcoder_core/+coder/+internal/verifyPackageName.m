function verifyPackageName( zipName )






if zipName ~= ""
[ p, fname, ext ] = fileparts( zipName );

fnameOK = ( strcmp( fname, zipName ) || strcmp( [ fname, ext ], zipName ) );
noFileSeps = isempty( regexp( fname, '[\\/]', 'once' ) );
if ~( isempty( p ) && fnameOK && noFileSeps )
error( message( 'RTW:configSet:RTWPackageNameFormat' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpS0Hqnu.p.
% Please follow local copyright laws when handling this file.

