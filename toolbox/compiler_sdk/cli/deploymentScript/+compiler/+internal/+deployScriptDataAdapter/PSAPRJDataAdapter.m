classdef PSAPRJDataAdapter < compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter




methods 
function obj = PSAPRJDataAdapter( prjData )
R36
prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
end 
obj = obj@compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter( prjData );
end 

function optValue = getOptionValue( obj, option )
R36
obj
option( 1, 1 )compiler.internal.option.DeploymentOption
end 

switch option
case compiler.internal.option.DeploymentOption.ArchiveName
optValue = obj.dataWrapper.getData(  ).param_appname;
case compiler.internal.option.DeploymentOption.FunctionFiles
optValue = obj.dataWrapper.getData(  ).fileset_exports.file;
case compiler.internal.option.DeploymentOption.FunctionSignatures
optValue = obj.dataWrapper.getData(  ).param_discovery_file;
otherwise 
optValue = obj.getBasicBuildOptionValue( option );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpXhy5iM.p.
% Please follow local copyright laws when handling this file.

