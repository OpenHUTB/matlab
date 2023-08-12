function out = newFileInfo( name, group, fileType, filePath, tag )
if nargin < 5

tag = '';
end 
out = struct( 'FileName', name, 'Group', group, 'Type', fileType, 'Path', filePath, 'Tag', tag );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmptl2O97.p.
% Please follow local copyright laws when handling this file.

