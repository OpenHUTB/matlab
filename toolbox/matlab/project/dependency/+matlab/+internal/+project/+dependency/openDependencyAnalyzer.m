function openDependencyAnalyzer( project, options )




R36
project( 1, 1 ){ mustBeA( project, [ "matlab.project.Project", "matlab.internal.project.api.Project" ] ) };
options.DependenciesOf( 1, : )string{ mustBeNonzeroLengthText } = string.empty;
options.DependencyType( 1, 1 )string{ mustBeMember( options.DependencyType, [ "upstream", "downstream", "all" ] ) } = "all";
end 

if matlab.internal.project.util.useWebFrontEnd
matlab.internal.project.view.postCommand( project.RootFolder, "openDependencyViewer", [ options.DependencyType, options.DependenciesOf ] );
elseif usejava( 'jvm' )
matlab.internal.project.util.processJavaCall( @(  )i_openJavaDependencyAnalyzer( project, options ) );
end 
end 

function i_openJavaDependencyAnalyzer( project, options )
controlset = com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory.getMatchingControlSet( java.io.File( project.RootFolder ) );

switch options.DependencyType
case "upstream"
key = com.mathworks.toolbox.slproject.extensions.dependency.GUI.analyzeview.ViewPanel.IMPACTED_KEY;
case "downstream"
key = com.mathworks.toolbox.slproject.extensions.dependency.GUI.analyzeview.ViewPanel.REQUIRED_KEY;
case "all"
key = com.mathworks.toolbox.slproject.extensions.dependency.GUI.analyzeview.ViewPanel.ALL_DEPENDENCIES_KEY;
end 

if isempty( options.DependenciesOf )
files = javaArray( 'java.io.File', 0 );
else 
files = arrayfun( @java.io.File, options.DependenciesOf );
end 

controlset.getFileTransferRegistry(  ).transfer( key, java.util.Arrays.asList( files ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpW_qDRV.p.
% Please follow local copyright laws when handling this file.

