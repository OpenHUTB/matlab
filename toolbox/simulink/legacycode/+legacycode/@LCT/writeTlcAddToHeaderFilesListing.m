function writeTlcAddToHeaderFilesListing( h, fid, headerFileList, spaceDelimiter )%#ok<INUSL>





if ~isempty( headerFileList )
for ii = 1:length( headerFileList )
thisHeader = headerFileList{ ii };
if thisHeader( 1 ) == '"'

thisHeader = thisHeader( 2:end  - 1 );
end 
fprintf( fid, '  %s%%<LibAddToCommonIncludes("%s")>\n',  ...
spaceDelimiter, thisHeader );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpQuxOU2.p.
% Please follow local copyright laws when handling this file.

