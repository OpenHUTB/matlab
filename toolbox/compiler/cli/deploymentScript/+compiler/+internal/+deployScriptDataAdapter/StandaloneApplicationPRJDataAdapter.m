classdef StandaloneApplicationPRJDataAdapter < compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter




properties 
InstallerAdapter
end 

methods 
function obj = StandaloneApplicationPRJDataAdapter( prjData )
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
case compiler.internal.option.DeploymentOption.AppFile
optValue = obj.dataWrapper.getData(  ).fileset_main.file;
case compiler.internal.option.DeploymentOption.ApplicationName
optValue = obj.dataWrapper.getData(  ).param_appname;
case compiler.internal.option.DeploymentOption.CustomHelpTextFile
if strcmp( obj.dataWrapper.getData(  ).param_checkbox, "false" )
optValue = obj.DEFAULT;
else 
customHelpText = strrep( obj.dataWrapper.getData(  ).param_help_text, newline, "\r\n" );

optValue.preLines = [ "helpTextFile = tempname;",  ...
"fileID = fopen(helpTextFile,'w');",  ...
"ensureFileCloseObject = onCleanup(@()fclose(fileID));",  ...
"fprintf(fileID, """ + customHelpText + """);",  ...
"ensureFileDeleteObject = onCleanup(@()delete(helpTextFile));" ];
optValue.value = double( 'helpTextFile' );
end 
case compiler.internal.option.DeploymentOption.EmbedArchive
optValue = ~contains( obj.dataWrapper.getData(  ).param_user_defined_mcr_options, "-C" );
case compiler.internal.option.DeploymentOption.ExecutableIcon
if isstruct( obj.dataWrapper.getData(  ).param_icons )
optValue = obj.dataWrapper.getData(  ).param_icons.file( 1 );
else 
optValue = obj.DEFAULT;
end 
case compiler.internal.option.DeploymentOption.ExecutableName
optValue = obj.dataWrapper.getData(  ).param_appname;
case compiler.internal.option.DeploymentOption.ExecutableSplashScreen
if obj.dataWrapper.getData(  ).param_screenshot == ""
optValue = obj.DEFAULT;
else 
optValue = obj.dataWrapper.getData(  ).param_screenshot;
end 
case compiler.internal.option.DeploymentOption.ExecutableVersion
optValue = obj.dataWrapper.getData(  ).param_version;
case compiler.internal.option.DeploymentOption.TreatInputsAsNumeric
optValue = strcmp( obj.dataWrapper.getData(  ).param_native_matlab, "true" );
otherwise 
if any( compiler.internal.option.DeploymentOption.allBuildTargetOptions == option )
optValue = obj.getBasicBuildOptionValue( option );
else 

optValue = obj.InstallerAdapter.getOptionValue( option );
end 
end 
end 

function isWinApp = isWindowsStandalone( obj )





isWinApp = strcmp( obj.dataWrapper.getData(  ).param_windows_command_prompt, "true" );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKYwbZ7.p.
% Please follow local copyright laws when handling this file.

