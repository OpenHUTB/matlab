classdef StandaloneBuildScriptGenerator < compiler.internal.deployScriptGenerator.DeployScriptGenerator


properties ( Constant, Access = private )
BUILD_OPTIONS_COMMAND = "compiler.build.StandaloneApplicationOptions";
BUILD_OPTS_VAR = "buildOpts";
end 

properties ( Access = private )
buildCommand
end 

methods 
function obj = StandaloneBuildScriptGenerator( adapter )
obj = obj@compiler.internal.deployScriptGenerator.DeployScriptGenerator( adapter );

obj.generatorOptions = [ compiler.internal.option.DeploymentOption.allBuildTargetOptions,  ...
compiler.internal.option.DeploymentOption.CustomHelpTextFile,  ...
compiler.internal.option.DeploymentOption.EmbedArchive,  ...
compiler.internal.option.DeploymentOption.ExecutableIcon,  ...
compiler.internal.option.DeploymentOption.ExecutableName,  ...
compiler.internal.option.DeploymentOption.ExecutableSplashScreen,  ...
compiler.internal.option.DeploymentOption.ExecutableVersion,  ...
compiler.internal.option.DeploymentOption.TreatInputsAsNumeric ];

if adapter.isWindowsStandalone(  )
obj.buildCommand = "compiler.build.standaloneWindowsApplication";
else 
obj.buildCommand = "compiler.build.standaloneApplication";
end 
end 

function script = generateScript( obj )
buildCreationArguments = obj.adapter.getOptionValue( compiler.internal.option.DeploymentOption.AppFile );

buildOptionsCreationLine = strcat( obj.BUILD_OPTS_VAR, " = ", obj.BUILD_OPTIONS_COMMAND, "(", obj.wrapInQuotes( buildCreationArguments ), ");" );
buildOptionsPropertySetLines = arrayfun( @( buildOpt )obj.serializeOption( buildOpt, obj.BUILD_OPTS_VAR ), obj.generatorOptions );
buildOptionsPropertySetLines = buildOptionsPropertySetLines( buildOptionsPropertySetLines ~= "" );
buildLine = strcat( obj.BUILD_RESULTS_VAR, " = ", obj.buildCommand, "(", obj.BUILD_OPTS_VAR, ");" );

script = strjoin( [ "% " + string( message( "Compiler:deploymentscript:buildIntro" ) ),  ...
buildOptionsCreationLine,  ...
buildOptionsPropertySetLines,  ...
buildLine ], newline );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpVINQn1.p.
% Please follow local copyright laws when handling this file.

