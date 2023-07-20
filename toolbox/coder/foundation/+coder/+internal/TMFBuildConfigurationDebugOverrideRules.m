classdef TMFBuildConfigurationDebugOverrideRules<coder.internal.BuildConfigurationDebugOverrideRules







    methods(Access=protected)
        function buildConfiguration_out=updateBuildConfiguration_Toolchain(~,buildConfiguration_in)





            buildConfiguration_out=buildConfiguration_in;
        end


        function customToolchainOptions_out=updateCustomToolchainOptions_Toolchain(~,~)





            customToolchainOptions_out={};
        end


        function customToolchainOptions_out=updateCustomToolchainOptions_Specify(obj,customToolchainOptions_in)





            customToolchainOptions_out=customToolchainOptions_in;
        end
    end

    methods(Access=public)
        function updateBuildInfo(~,buildInfo)

            removeBuildArgs(buildInfo,'DEBUG_BUILD');
            addBuildArgs(buildInfo,'DEBUG_BUILD','1','MakeArg');
        end
    end
end
