function writeTlcAddToSourceFilesListing( h, fid, sourceFileList, spaceDelimiter )%#ok<INUSL>





if ~isempty( sourceFileList )
for ii = 1:length( sourceFileList )


tmpFile = strrep( sourceFileList{ ii }, '\', '\\' );




fprintf( fid, '  %s%%<SLibAddToStaticSources("%s")>\n', spaceDelimiter, tmpFile );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp8cTILm.p.
% Please follow local copyright laws when handling this file.

