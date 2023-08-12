classdef ( Abstract )AbstractBuildPRJDataAdapter < compiler.internal.deployScriptDataAdapter.DataAdapter




methods 
function obj = AbstractBuildPRJDataAdapter( prjData )
R36
prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
end 
obj = obj@compiler.internal.deployScriptDataAdapter.DataAdapter( prjData );
end 
end 

methods ( Access = protected )
function optValue = getBasicBuildOptionValue( obj, option )
R36
obj
option( 1, 1 )compiler.internal.option.DeploymentOption
end 

switch option
case compiler.internal.option.DeploymentOption.AdditionalFiles
resource_files = obj.dataWrapper.getData(  ).fileset_resources;
if ( strcmp( resource_files, "" ) )
optValue = obj.DEFAULT;
else 
optValue = resource_files.file;
end 
case compiler.internal.option.DeploymentOption.AutoDetectDataFiles
optValue = ~contains( obj.dataWrapper.getData(  ).param_user_defined_mcr_options, "-X" );
case compiler.internal.option.DeploymentOption.OutputDirBuild
optValue = fullfile( obj.dataWrapper.getData(  ).param_intermediate );
case compiler.internal.option.DeploymentOption.SupportPackages
optValue = obj.DEFAULT;
case compiler.internal.option.DeploymentOption.Verbose
optValue = true;
otherwise 
error( message( "Compiler:deploymentscript:invalidAdapterOption", string( option ) ) );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpgJPDxl.p.
% Please follow local copyright laws when handling this file.

