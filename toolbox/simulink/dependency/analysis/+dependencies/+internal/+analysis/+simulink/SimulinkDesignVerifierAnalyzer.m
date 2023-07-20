classdef SimulinkDesignVerifierAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        SimulinkDesignVerifierType='SimulinkDesignVerifier';
    end

    methods

        function this=SimulinkDesignVerifierAnalyzer()
            import dependencies.internal.analysis.simulink.queries.ConfigSetQuery
            queries.SldvConfig=ConfigSetQuery('Sldv.ConfigComp','DVParametersConfigFileName');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            files=matches.SldvConfig.Value;
            configset=matches.SldvConfig.Configset;

            deps=dependencies.internal.graph.Dependency.empty;

            notUnderMatlabRootFilter=~dependencies.internal.graph.NodeFilter.fileWithin({matlabroot});
            for n=1:length(files)
                if~isempty(files{n})
                    target=handler.Resolver.findFile(node,files{n},[".p",".m",".mlx"]);
                    if(files{n}~="sldv_params_template.m")||notUnderMatlabRootFilter.apply(target)
                        deps(end+1)=dependencies.internal.graph.Dependency(...
                        node,'',target,'',[this.SimulinkDesignVerifierType,',',configset{n}]);%#ok<AGROW>
                    end
                end
            end
        end

    end

end
