classdef WebAppArchiveBuildScriptGenerator < compiler.internal.deployScriptGenerator.DeployScriptGenerator


properties ( Constant, Access = private )
BUILD_COMMAND = "compiler.build.webAppArchive";
BUILD_OPTIONS_COMMAND = "compiler.build.WebAppArchiveOptions";
BUILD_OPTS_VAR = "buildOpts";
end 

methods 
function obj = WebAppArchiveBuildScriptGenerator( adapter )
obj = obj@compiler.internal.deployScriptGenerator.DeployScriptGenerator( adapter );

obj.generatorOptions = [ compiler.internal.option.DeploymentOption.allBuildTargetOptions,  ...
compiler.internal.option.DeploymentOption.ArchiveName ];
end 

function script = generateScript( obj )
buildCreationArguments = obj.adapter.getOptionValue( compiler.internal.option.DeploymentOption.AppFile );

buildOptionsCreationLine = strcat( obj.BUILD_OPTS_VAR, " = ", obj.BUILD_OPTIONS_COMMAND, "(", obj.wrapInQuotes( buildCreationArguments ), ");" );
buildOptionsPropertySetLines = arrayfun( @( buildOpt )obj.serializeOption( buildOpt, obj.BUILD_OPTS_VAR ), obj.generatorOptions );
buildOptionsPropertySetLines = buildOptionsPropertySetLines( buildOptionsPropertySetLines ~= "" );
buildLine = strcat( obj.BUILD_RESULTS_VAR, " = ", obj.BUILD_COMMAND, "(", obj.BUILD_OPTS_VAR, ");" );

script = strjoin( [ "% " + string( message( "Compiler:deploymentscript:buildIntro" ) ),  ...
buildOptionsCreationLine,  ...
buildOptionsPropertySetLines,  ...
buildLine ], newline );
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmphCq7k3.p.
% Please follow local copyright laws when handling this file.

