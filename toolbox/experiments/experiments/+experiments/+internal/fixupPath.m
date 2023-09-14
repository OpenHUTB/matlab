function filePath = fixupPath( root, filePath )

R36
root{ mustBeMember( root, { 'matlab', 'project' } ) }
filePath( 1, : )char
end 
switch root
case 'matlab'
prefix = matlabroot;
case 'project'
prefix = experiments.internal.JSProjectService.getCurrentProjectPath(  );
end 
if ispc

filePath = strrep( filePath, '/', '\' );
end 
filePath = fullfile( prefix, filePath );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpyJIzvr.p.
% Please follow local copyright laws when handling this file.

