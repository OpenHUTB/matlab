function showFilesInProject( project, files )




R36
project( 1, 1 ){ mustBeA( project, [ "matlab.project.Project", "matlab.internal.project.api.Project" ] ) };
files( 1, : )string{ mustBeNonzeroLengthText };
end 

if matlab.internal.project.util.useWebFrontEnd
if ~isempty( files )
matlab.internal.project.view.showFileInProject( project.RootFolder, files( 1 ) );
end 
elseif usejava( 'jvm' )
i_javaShowFilesInProject( project.RootFolder, files );
end 
end 

function i_javaShowFilesInProject( projectRoot, files )
import com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory;
import com.mathworks.toolbox.slproject.project.GUI.fileviews.ProjectFilesView;
matlab.project.show(  );
controlset = MatlabAPIFacadeFactory.getMatchingControlSet( java.io.File( projectRoot ) );
if ~isempty( controlset )
jFiles = java.util.Arrays.asList( java.io.File( files ) );
controlset.getFileTransferRegistry(  ).transfer( ProjectFilesView.TRANSFER_KEY, jFiles );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJPzCim.p.
% Please follow local copyright laws when handling this file.

