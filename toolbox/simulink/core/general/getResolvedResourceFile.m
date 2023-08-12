function filename = getResolvedResourceFile( model, filename )




if isa( model, 'char' )
model = get_param( model, 'Handle' );
end 

variableUnpackedFolder = '[$unpackedFolder]';
prefixLength = length( variableUnpackedFolder );

if ( ~strncmp( filename, variableUnpackedFolder, prefixLength ) )
filename = [  ];
else 
unpackedFolder = get_param( model, 'UnpackedLocation' );
filename = strrep( filename, variableUnpackedFolder, unpackedFolder );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDTGDz8.p.
% Please follow local copyright laws when handling this file.

