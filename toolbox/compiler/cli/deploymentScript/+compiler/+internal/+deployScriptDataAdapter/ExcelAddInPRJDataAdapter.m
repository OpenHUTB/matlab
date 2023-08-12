classdef ExcelAddInPRJDataAdapter < compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter




properties 
InstallerAdapter
end 

methods 
function obj = ExcelAddInPRJDataAdapter( prjData )
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

case compiler.internal.option.DeploymentOption.AddInName
optValue = obj.dataWrapper.getData(  ).param_appname;
case compiler.internal.option.DeploymentOption.AddInVersion
optValue = obj.dataWrapper.getData(  ).param_version;
case compiler.internal.option.DeploymentOption.ClassName
theClasses = [ obj.dataWrapper.getData(  ).fileset_classes.entity_package.entity_class.nameAttribute ];
optValue = theClasses( 1 );
case compiler.internal.option.DeploymentOption.DebugBuild
optValue = contains( obj.dataWrapper.getData(  ).param_user_defined_mcr_options, [ "-g", "-G" ] );
case compiler.internal.option.DeploymentOption.EmbedArchive
optValue = ~contains( obj.dataWrapper.getData(  ).param_user_defined_mcr_options, "-C" );
case compiler.internal.option.DeploymentOption.FunctionFiles
optValue = obj.dataWrapper.getData(  ).fileset_exports.file;
case compiler.internal.option.DeploymentOption.GenerateVisualBasicFile
optValue = obj.DEFAULT;
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpY8HurP.p.
% Please follow local copyright laws when handling this file.

