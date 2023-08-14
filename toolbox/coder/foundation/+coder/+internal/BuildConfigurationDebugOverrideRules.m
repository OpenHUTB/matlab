classdef(Abstract)BuildConfigurationDebugOverrideRules<handle









    methods(Abstract,Access=protected)


        buildConfiguration_out=updateBuildConfiguration_Toolchain(obj,buildConfiguration_in)



        customToolchainOptions_out=updateCustomToolchainOptions_Toolchain(obj,buildConfiguration_in)



        customToolchainOptions_out=updateCustomToolchainOptions_Specify(obj,customToolchainOptions_in)
    end


    methods(Access=public)
        function buildConfiguration_out=updateBuildConfiguration(obj,buildConfiguration_in)
            if strcmp(buildConfiguration_in,'Specify')
                buildConfiguration_out=buildConfiguration_in;
            else
                buildConfiguration_out=obj.updateBuildConfiguration_Toolchain(buildConfiguration_in);
            end
        end

        function customToolchainOptions_out=updateCustomToolchainOptions(obj,buildConfiguration_in,customToolchainOptions_in)
            if strcmp(buildConfiguration_in,'Specify')
                customToolchainOptions_out=obj.updateCustomToolchainOptions_Specify(customToolchainOptions_in);
            else
                customToolchainOptions_out=obj.updateCustomToolchainOptions_Toolchain(buildConfiguration_in);
            end
        end

        function updateBuildInfo(~,buildInfo)%#ok<INUSD>

        end
    end
end