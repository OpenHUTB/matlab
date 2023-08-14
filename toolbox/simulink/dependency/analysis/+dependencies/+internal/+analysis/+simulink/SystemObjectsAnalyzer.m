classdef SystemObjectsAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        SystemObjectType=dependencies.internal.graph.Type("SystemObject");
    end

    methods

        function this=SystemObjectsAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery

            queries.MatlabSystemBlock=createParameterQuery("System","BlockType","MATLABSystem");
            queries.DiscreteEvent=createParameterQuery("System","BlockType","MATLABDiscreteEventSystem");
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            systemBlockDeps=this.createDependencies(handler,node,matches.MatlabSystemBlock);
            discreteEventDeps=this.createDependencies(handler,node,matches.DiscreteEvent);
            deps=[systemBlockDeps,discreteEventDeps];
        end

    end

    methods(Access=private)
        function deps=createDependencies(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;

            for n=1:length(matches.Value)
                filename=matches.Value{n};
                if~isempty(filename)
                    upComp=Component.createBlock(node,matches.BlockPath{n},handler.getSID(matches.BlockPath{n}));
                    target=dependencies.internal.analysis.findSymbol(filename);
                    deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                    upComp,target,this.SystemObjectType);%#ok<AGROW>
                end
            end
        end
    end

end
