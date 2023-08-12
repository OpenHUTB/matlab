function removeFileInfo( reportInfo, fileName, filePath )







existingFileInfo = getFileInfo( reportInfo, fileName );

if isempty( existingFileInfo )
return 
end 


matchIdx = strcmp( { existingFileInfo.Path }, filePath );
if ~any( matchIdx )
return 
end 


existingFileInfo = existingFileInfo( matchIdx );


existingFileInfo = reportInfo.tokenPath( existingFileInfo );


for i = 1:length( existingFileInfo )
pathMatchIdx = strcmp( existingFileInfo( i ).Path, { reportInfo.FileInfo.Path } );
nameMatchIdx = strcmp( existingFileInfo( i ).FileName, { reportInfo.FileInfo.FileName } );
matchIdx = pathMatchIdx & nameMatchIdx;
reportInfo.FileInfo = reportInfo.FileInfo( ~matchIdx );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphdeg5f.p.
% Please follow local copyright laws when handling this file.

