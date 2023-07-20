classdef ModelCallbackAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        ModelCallbacks={...
        'CloseFcn',...
        'InitFcn',...
        'PostLoadFcn',...
        'PostSaveFcn',...
        'PreLoadFcn',...
        'PreSaveFcn',...
        'StartFcn',...
        'StopFcn',...
        'PauseFcn',...
'ContinueFcn'
        };
    end

    methods

        function this=ModelCallbackAnalyzer()
            import dependencies.internal.analysis.simulink.queries.ModelParameterQuery
            for n=1:length(this.ModelCallbacks)
                queries.(this.ModelCallbacks{n})=ModelParameterQuery(this.ModelCallbacks{n});
            end
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;


            for n=1:length(this.ModelCallbacks)
                type=['ModelCallback,',this.ModelCallbacks{n}];
                factory=dependencies.internal.analysis.DependencyFactory(...
                handler,Component.createRoot(node),type);
                if~isempty(matches.(this.ModelCallbacks{n}).Value)
                    code=matches.(this.ModelCallbacks{n}).Value(:);
                    deps=[deps,handler.Analyzers.MATLAB.analyze(code,factory)];%#ok<AGROW>
                end
            end
        end

    end

end
