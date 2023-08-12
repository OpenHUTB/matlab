function out = getFileInfoByGroup( obj, group )
narginchk( 2, 2 );
if isempty( obj.FileInfo )
out = [  ];
return 
end 
idx = find( strcmp( { obj.FileInfo.Group }, group ) );
if isempty( idx )
out = [  ];
else 
fileInfo = obj.getFileInfo;
out = fileInfo( idx );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTV92dK.p.
% Please follow local copyright laws when handling this file.

