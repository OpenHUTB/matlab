function out = isFileUptodate( obj, group )




legacyFiles = obj.getFileInfoByGroup( group );
out = true;

dataJsFilePath = fullfile( obj.getReportDir, 'data', 'data.js' );
checkDataJS = obj.featureReportV2 && exist( dataJsFilePath, 'file' );
for i = 1:length( legacyFiles )
sourceFile = fullfile( legacyFiles( i ).Path, legacyFiles( i ).FileName );
if checkDataJS


htmlFile = dataJsFilePath;
else 
htmlFile = fullfile( obj.getReportDir, obj.getHTMLFileName( sourceFile ) );
end 
d_source = dir( sourceFile );
d_html = dir( htmlFile );
if isempty( d_source ) || isempty( d_html )
out = false;
return 
end 
if ( d_source.datenum > d_html.datenum )
out = false;
return 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpsUT2Hh.p.
% Please follow local copyright laws when handling this file.

