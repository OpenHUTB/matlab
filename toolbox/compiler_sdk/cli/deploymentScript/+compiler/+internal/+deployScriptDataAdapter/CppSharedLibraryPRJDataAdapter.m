classdef CppSharedLibraryPRJDataAdapter < compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter




properties 
InstallerAdapter
end 

methods 
function obj = CppSharedLibraryPRJDataAdapter( prjData )
R36
prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
end 
obj = obj@compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter( prjData );
obj.InstallerAdapter = compiler.internal.deployScriptDataAdapter.InstallerPRJDataAdapter( prjData );
end 

function optValue = getOptionValue( obj, option )
R36
obj
option( 1, 1 )compiler.internal.option.DeploymentOption
end 

switch option
case compiler.internal.option.DeploymentOption.DebugBuild
optValue = contains( obj.dataWrapper.getData(  ).param_user_defined_mcr_options, [ "-g", "-G" ] );
case compiler.internal.option.DeploymentOption.FunctionFiles
optValue = obj.dataWrapper.getData(  ).fileset_exports.file;
case compiler.internal.option.DeploymentOption.Interface
if ( strcmp( obj.dataWrapper.getData(  ).param_cpp_api, "option.cpp.legacy" ) )
optValue = "mwarray";
elseif ( strcmp( obj.dataWrapper.getData(  ).param_cpp_api, "option.cpp.all" ) )
optValue = "all";
else 
optValue = "matlab-data";
end 
case compiler.internal.option.DeploymentOption.LibraryName
optValue = obj.dataWrapper.getData(  ).param_appname;
case compiler.internal.option.DeploymentOption.LibraryVersion
optValue = obj.dataWrapper.getData(  ).param_version;
case compiler.internal.option.DeploymentOption.SampleGenerationFiles
sample_files = obj.dataWrapper.getData(  ).fileset_examples;
if ( strcmp( sample_files, "" ) )
optValue = obj.DEFAULT;
else 
optValue = sample_files.file;
end 
otherwise 
if any( compiler.internal.option.DeploymentOption.allBuildTargetOptions == option )
optValue = obj.getBasicBuildOptionValue( option );
else 

optValue = obj.InstallerAdapter.getOptionValue( option );
end 
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpbMehMi.p.
% Please follow local copyright laws when handling this file.

