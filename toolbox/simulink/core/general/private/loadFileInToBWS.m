function result = loadFileInToBWS(  )






recognizedFileType = [ DAStudio.message( 'Simulink:dialog:WorkspaceRecognizedFileFormat' ), ' (*.mat, *.m)' ];
[ fileNameExt, pathName ] = uigetfile( { '*.mat;*.m', recognizedFileType;'*.mat', 'MAT-files (*.mat)';'*.m', 'MATLAB-files (*.m)' },  ...
DAStudio.message( 'Simulink:dialog:WorkspaceImportFileDialogName' ) );
result = false;
if ~( isequal( fileNameExt, 0 ) )
[ ~, ~, ext ] = fileparts( fileNameExt );
if isequal( ext, '.m' )
cmd = 'run';
else 

cmd = 'load';
end 

evalin( 'base', [ cmd, '(fullfile(''', [ pathName, fileNameExt ], '''))' ] );
result = true;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp0Uamly.p.
% Please follow local copyright laws when handling this file.

