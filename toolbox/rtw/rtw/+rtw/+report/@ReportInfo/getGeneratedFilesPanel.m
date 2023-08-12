function out = getGeneratedFilesPanel( obj )




[ sortedFileInfoList, srcFiles_cat, categoriesId, categoriesMsg ] = obj.getSortedFileInfoList;
out = coder.internal.slcoderReport( 'getGeneratedFilesPanel', sortedFileInfoList, srcFiles_cat, categoriesId, categoriesMsg, obj.getReportDir, obj );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIras2c.p.
% Please follow local copyright laws when handling this file.

