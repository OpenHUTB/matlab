classdef COMComponentPRJDataAdapter < compiler.internal.deployScriptDataAdapter.ClassBasedPRJDataAdapter




methods 
function obj = COMComponentPRJDataAdapter( prjData )
R36
prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
end 
obj = obj@compiler.internal.deployScriptDataAdapter.ClassBasedPRJDataAdapter( prjData );
end 

function optValue = getOptionValue( obj, option )
R36
obj
option( 1, 1 )compiler.internal.option.DeploymentOption
end 

switch option

case compiler.internal.option.DeploymentOption.ComponentName
optValue = obj.dataWrapper.getData(  ).param_appname;
case compiler.internal.option.DeploymentOption.ComponentVersion
optValue = obj.dataWrapper.getData(  ).param_version;
case compiler.internal.option.DeploymentOption.EmbedArchive
optValue = ~contains( obj.dataWrapper.getData(  ).param_user_defined_mcr_options, "-C" );
otherwise 
optValue = obj.getSharedClassBasedLibraryOptionValue( option );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpEdLvm_.p.
% Please follow local copyright laws when handling this file.

