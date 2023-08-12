classdef ToolchainBuildConfigurationDebugOverrideRules < coder.internal.BuildConfigurationDebugOverrideRules










properties ( GetAccess = private, SetAccess = immutable )
Toolchain
end 

methods ( Access = public )
function obj = ToolchainBuildConfigurationDebugOverrideRules( toolchainInfo )

R36
toolchainInfo( 1, 1 )
end 
obj.Toolchain = toolchainInfo;
end 
end 

methods ( Access = protected )
function buildConfiguration_out = updateBuildConfiguration_Toolchain( ~, ~ )




buildConfiguration_out = 'Specify';
end 


function customToolchainOptions_out = updateCustomToolchainOptions_Toolchain( obj, buildConfiguration_in )





lCustomToolchainOptions = coder.make.internal.getToolsAndOptionsFromToolchain( obj.Toolchain, buildConfiguration_in );



customToolchainOptions_out = obj.updateCustomToolchainOptions_Specify( lCustomToolchainOptions );
end 


function customToolchainOptions_out = updateCustomToolchainOptions_Specify( obj, customToolchainOptions_in )




customToolchainOptions_out = coder.make.internal.applyDebugOptions( obj.Toolchain, customToolchainOptions_in );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp46FfnP.p.
% Please follow local copyright laws when handling this file.

