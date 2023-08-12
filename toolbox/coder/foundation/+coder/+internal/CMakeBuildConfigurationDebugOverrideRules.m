classdef CMakeBuildConfigurationDebugOverrideRules < coder.internal.BuildConfigurationDebugOverrideRules









properties ( GetAccess = private, SetAccess = immutable )
TFToolchain
end 

methods ( Access = public )
function obj = CMakeBuildConfigurationDebugOverrideRules( toolchainInfo )

R36
toolchainInfo( 1, 1 )coder.make.internal.adapter.IToolchain
end 
obj.TFToolchain = toolchainInfo.getWrappedObject(  );
end 
end 

methods ( Access = protected )
function buildConfiguration_out = updateBuildConfiguration_Toolchain( obj, buildConfiguration_in )




buildConfiguration_out = obj.getDebugBuildType( buildConfiguration_in );
end 


function customToolchainOptions_out = updateCustomToolchainOptions_Toolchain( ~, ~ )




customToolchainOptions_out = {  };
end 


function customToolchainOptions_out = updateCustomToolchainOptions_Specify( obj, customToolchainOptions_in )




customToolchainOptions_out = obj.applyDebugOptionsForCMake( customToolchainOptions_in );
end 
end 


methods ( Access = private )
function ret = getDebugBuildType( obj, buildType )





R36
obj
buildType( 1, : )char
end 

assert( ~isempty( obj.TFToolchain.Builder ) &&  ...
isa( obj.TFToolchain.Builder, 'target.internal.CMakeBuilder' ),  ...
'Toolchain %s is not configured for CMake', obj.TFToolchain.Name );

ret = '';
buildTypeObj = obj.TFToolchain.Builder.SupportedBuildTypes(  ...
strcmp( { obj.TFToolchain.Builder.SupportedBuildTypes.Name }, buildType ) );
if ~isempty( buildTypeObj )
if buildTypeObj.GeneratesDebugSymbols


ret = buildType;
elseif ~isempty( buildTypeObj.DebugBuildType )



ret = buildTypeObj.DebugBuildType;
end 
end 

if isempty( ret )


error( message( 'CoderFoundation:toolchain:CMakeDebugBuildConfigurationNeeded',  ...
buildType, obj.TFToolchain.Name ) );
end 
end 

function lCustomToolchainOptions_out = applyDebugOptionsForCMake( obj, lCustomToolchainOptions )






R36
obj
lCustomToolchainOptions cell
end 

assert( ~isempty( obj.TFToolchain.Builder ) && isa( obj.TFToolchain.Builder, 'target.internal.CMakeBuilder' ),  ...
'Toolchain has no CMakeBuilder' );
lCustomToolchainOptionsObj = coder.make.internal.CustomToolchainOptions( lCustomToolchainOptions );
default = 'Debug';
if obj.TFToolchain.Builder.GeneratorIsMultiConfig
buildOptionPattern = '(?<=--config\s+)"?([^ \f\n\r\t\v"]*)\"?';
obj.doReplace( lCustomToolchainOptionsObj, 'CMake Build', buildOptionPattern, [ '--config ', default ] );
else 
configureOptionPattern = '(?<=-D\s*CMAKE_BUILD_TYPE\s*=\s*)"?([^ \f\n\r\t\v"]*)"?';
obj.doReplace( lCustomToolchainOptionsObj, 'CMake Configure', configureOptionPattern, [ '-DCMAKE_BUILD_TYPE=', default ] );
end 
lCustomToolchainOptions_out = lCustomToolchainOptionsObj.RawCustomToolchainOptions;
end 


function doReplace( obj, lCustomToolchainOptionsObj, optionName, optionPattern, default )

optionValue = lCustomToolchainOptionsObj.getValue( optionName );
buildType = regexp( optionValue, optionPattern, 'tokens', 'once' );
if isempty( buildType )
optionValue = [ optionValue, ' ', default ];
else 
debugBuildType = obj.getDebugBuildType( buildType{ 1 } );
optionValue = regexprep( optionValue, optionPattern, debugBuildType );
end 
lCustomToolchainOptionsObj.setValue( optionName, optionValue );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpd3BHFS.p.
% Please follow local copyright laws when handling this file.

