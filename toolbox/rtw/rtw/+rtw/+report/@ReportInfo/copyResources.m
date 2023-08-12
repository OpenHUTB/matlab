function copyResources( obj )
copyResources@Simulink.report.ReportInfo( obj );
if ~rtw.report.ReportInfo.DisplayInCodeTrace || obj.hasWebview
return 
end 
files = { fullfile( 'css', 'coder_app.css' ), fullfile( 'js', 'coder_app.js' ), 'spinner.gif' };
dst_folders = { obj.getReportDir };
sharedUtil = ~isempty( obj.GenUtilsPath ) && ~strcmp( obj.GenUtilsPath, obj.BuildDirectory );
if sharedUtil
dst_folders{ end  + 1 } = fullfile( obj.GenUtilsPath, 'html' );
end 

for i = 1:length( dst_folders )
tmp = fullfile( dst_folders{ i }, 'css' );
if ~exist( tmp, 'dir' )
rtwprivate( 'rtw_create_directory_path', tmp );
end 
tmp = fullfile( dst_folders{ i }, 'js' );
if ~exist( tmp, 'dir' )
rtwprivate( 'rtw_create_directory_path', tmp );
end 
for j = 1:length( files )
srcFile = fullfile( Simulink.report.ReportInfo.getResourceDir, files{ j } );
dstFile = fullfile( dst_folders{ i }, files{ j } );
coder.internal.coderCopyfile( srcFile, dstFile );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpAsU_Uz.p.
% Please follow local copyright laws when handling this file.

