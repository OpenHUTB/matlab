function result = getQualifiedFileName( aFilePath )

























R36
aFilePath( 1, : )char
end 
[ parentPath, fileName ] = fileparts( aFilePath );
if isempty( parentPath )

result = aFilePath;
else 
[ ~, parentDirName ] = fileparts( parentPath );
if isClassDirectoryName( parentDirName ) && ~strcmp( parentDirName( 2:end  ), fileName )

result = fileName;
else 
result = matlab.internal.language.introspective.containers.getQualifiedFileName( aFilePath );
end 
end 
end 

function result = isClassDirectoryName( aDirectoryName )
R36
aDirectoryName( 1, : )char
end 
result = numel( aDirectoryName ) >= 2 && aDirectoryName( 1 ) == '@';
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKpeqUd.p.
% Please follow local copyright laws when handling this file.

