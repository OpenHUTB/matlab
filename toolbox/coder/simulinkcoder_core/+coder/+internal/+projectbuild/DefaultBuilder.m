classdef(Hidden)DefaultBuilder<coder.internal.projectbuild.Builder





    properties(GetAccess=private,SetAccess=immutable)
        SlBuildArguments={};
    end

    methods


        function this=DefaultBuilder(model,varargin)
            this@coder.internal.projectbuild.Builder(model);

            this.SlBuildArguments=varargin;
        end



        function build(this)
            slprivate('slbuild_private',this.Model,this.SlBuildArguments{:});
        end
    end
end
