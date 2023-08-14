classdef LegacyBuildToolsCompatibility<handle








    properties(SetAccess=private,GetAccess=public)
        BuildVariant;
        BuildActions;
        BuildOpts;
    end

    properties(SetAccess=private,GetAccess=public)

        ToolchainInfo;
        Toolchain;
    end

    methods

        function this=LegacyBuildToolsCompatibility(lToolchainInfo,buildName)
            if~isempty(lToolchainInfo)
                this.Toolchain=lToolchainInfo.Name;
            end
            this.ToolchainInfo=lToolchainInfo;
            lBuildOpts.buildName=buildName;
            this.BuildOpts=lBuildOpts;
        end

        function setBuildVariant(this,val)

            if~isa(val,'coder.make.enum.BuildVariant')
                val=coder.make.enum.BuildVariant(val);
            end
            this.BuildVariant=val;

        end

        function setBuildActions(this,val)

            if~isa(val,'coder.make.enum.BuildAction')
                val=coder.make.enum.BuildAction(val);
            end
            this.BuildActions=val;

        end
    end
end
