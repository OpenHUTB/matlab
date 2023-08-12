function trimFileSet( obj )

newFInfoCounter = 1;
for i = 1:length( obj.FileInfo )
[ ~, ~, ext ] = fileparts( obj.FileInfo( i ).FileName );
if ~( strcmp( ext, '.cpp' ) || strcmp( ext, '.c' ) )
newFileInfo( newFInfoCounter ) = obj.FileInfo( i );
newFInfoCounter = newFInfoCounter + 1;
end 
end 
obj.FileInfo = newFileInfo;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgMpc8U.p.
% Please follow local copyright laws when handling this file.

