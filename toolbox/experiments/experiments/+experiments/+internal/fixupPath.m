function filePath = fixupPath( root, filePath )

arguments
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


