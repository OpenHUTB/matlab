classdef InstallerPRJDataAdapter < compiler.internal.deployScriptDataAdapter.DataAdapter




methods 
function obj = InstallerPRJDataAdapter( prjData )
R36
prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
end 
obj = obj@compiler.internal.deployScriptDataAdapter.DataAdapter( prjData );
end 

function optValue = getOptionValue( obj, option )
R36
obj
option( 1, 1 )compiler.internal.option.DeploymentOption
end 

switch option
case compiler.internal.option.DeploymentOption.AdditionalInstallerFiles
installer_files = obj.dataWrapper.getData(  ).fileset_package;
if ( strcmp( installer_files, "" ) )
optValue = obj.DEFAULT;
else 
optValue = installer_files.file;
end 
case compiler.internal.option.DeploymentOption.AddRemoveProgramsIcon

if isstruct( obj.dataWrapper.getData(  ).param_icons )
optValue = obj.dataWrapper.getData(  ).param_icons.file( 1 );
else 
optValue = obj.DEFAULT;
end 
case compiler.internal.option.DeploymentOption.ApplicationName
optValue = obj.dataWrapper.getData(  ).param_appname;
case compiler.internal.option.DeploymentOption.AuthorCompany
optValue = obj.dataWrapper.getData(  ).param_company;
case compiler.internal.option.DeploymentOption.AuthorEmail
optValue = obj.dataWrapper.getData(  ).param_email;
case compiler.internal.option.DeploymentOption.AuthorName
optValue = obj.dataWrapper.getData(  ).param_authnamewatermark;
case compiler.internal.option.DeploymentOption.Description
optValue = obj.dataWrapper.getData(  ).param_description;
case compiler.internal.option.DeploymentOption.DefaultInstallationDir




if ispc
if strcmp( obj.dataWrapper.getData(  ).param_installpath_combo, "option.installpath.appdata" )
instRoot = "%AppData%";
else 
instRoot = "%ProgramFiles%";
end 
elseif ismac
instRoot = "/Applications";
else 
if strcmp( obj.dataWrapper.getData(  ).param_installpath_combo, "option.installpath.user" )
instRoot = "/usr";
else 
instRoot = "/usr/local";
end 
end 
optValue = fullfile( instRoot, obj.dataWrapper.getData(  ).param_installpath_string );
case compiler.internal.option.DeploymentOption.InstallerIcon
if isstruct( obj.dataWrapper.getData(  ).param_icons )
optValue = obj.dataWrapper.getData(  ).param_icons.file( 1 );
else 
optValue = obj.DEFAULT;
end 
case compiler.internal.option.DeploymentOption.InstallerLogo
optValue = obj.dataWrapper.getData(  ).param_logo;
case compiler.internal.option.DeploymentOption.InstallerName
if strcmp( obj.dataWrapper.getData(  ).param_web_mcr, "true" )
optValue = obj.dataWrapper.getData(  ).param_web_mcr_name;
else 
optValue = obj.dataWrapper.getData(  ).param_package_mcr_name;
end 
case compiler.internal.option.DeploymentOption.InstallerSplash
optValue = obj.dataWrapper.getData(  ).param_screenshot;
case compiler.internal.option.DeploymentOption.InstallationNotes
optValue = obj.dataWrapper.getData(  ).param_install_notes;
case compiler.internal.option.DeploymentOption.OutputDirPackage
optValue = fullfile( obj.dataWrapper.getData(  ).param_output );
case compiler.internal.option.DeploymentOption.RuntimeDelivery
if ( strcmp( obj.dataWrapper.getData(  ).param_package_mcr, "true" ) )
optValue = "installer";
else 
optValue = "web";
end 
case compiler.internal.option.DeploymentOption.Shortcut
optValue = obj.DEFAULT;
case compiler.internal.option.DeploymentOption.Summary
optValue = obj.dataWrapper.getData(  ).param_summary;
case compiler.internal.option.DeploymentOption.Version
optValue = obj.dataWrapper.getData(  ).param_version;
otherwise 
error( message( "Compiler:deploymentscript:invalidAdapterOption", string( option ) ) );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBYS_tc.p.
% Please follow local copyright laws when handling this file.

