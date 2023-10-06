classdef(Abstract)ModelAnalyzer<handle&matlab.mixin.Heterogeneous
    properties(GetAccess=public,SetAccess=immutable)

        Queries(1,1)dependencies.internal.analysis.simulink.QueryTable;

        AlwaysAnalyze(1,1)logical;
    end

    methods(Access=public)
        function this=ModelAnalyzer(alwaysAnalyze)
            this.Queries=dependencies.internal.analysis.simulink.QueryTable;
            if nargin==0
                this.AlwaysAnalyze=false;
            else
                this.AlwaysAnalyze=alwaysAnalyze;
            end
        end
    end

    methods(Abstract,Access=public)

        dependencies=analyze(this,handler,node,matches);
    end

    methods(Access=protected)
        function addQueries(this,queries,varargin)

            this.Queries.addQueries(queries,varargin{:});
        end
    end

end

