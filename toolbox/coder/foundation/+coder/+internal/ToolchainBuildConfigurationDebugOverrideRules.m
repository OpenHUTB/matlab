classdef ToolchainBuildConfigurationDebugOverrideRules < coder.internal.BuildConfigurationDebugOverrideRules

    properties ( GetAccess = private, SetAccess = immutable )
        Toolchain
    end

    methods ( Access = public )
        function obj = ToolchainBuildConfigurationDebugOverrideRules( toolchainInfo )

            arguments
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


