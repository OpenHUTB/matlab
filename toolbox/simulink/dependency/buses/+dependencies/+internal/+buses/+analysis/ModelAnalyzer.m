classdef(Abstract)ModelAnalyzer<handle&matlab.mixin.Heterogeneous






    properties(GetAccess=public,SetAccess=immutable)

        AlwaysAnalyze(1,1)logical;
    end

    methods(Access=public)
        function this=ModelAnalyzer(alwaysAnalyze)
            if nargin==0
                this.AlwaysAnalyze=false;
            else
                this.AlwaysAnalyze=alwaysAnalyze;
            end
        end
    end

    methods(Abstract,Access=public)

        table=getQueryTable(this,busNode);


        dependencies=analyze(this,mdlInfo,busNode,fileNode,matches);
    end

end

