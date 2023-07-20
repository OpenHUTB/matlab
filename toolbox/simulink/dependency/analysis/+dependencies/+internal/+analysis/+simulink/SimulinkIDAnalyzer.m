classdef SimulinkIDAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    methods

        function this=SimulinkIDAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createAnnotationParameterQuery

            queries.BlockSID=createParameterQuery('SID');
            queries.AnnotationSID=createAnnotationParameterQuery('SID');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(~,handler,~,matches)
            deps=dependencies.internal.graph.Dependency.empty;

            sids=[matches.BlockSID.Value,matches.AnnotationSID.Value];
            paths=[matches.BlockSID.BlockPath,matches.AnnotationSID.BlockPath];

            sidMap=containers.Map(sids,paths);
            handler.setSIDMap(sidMap);

            pathToSIDMap=containers.Map(paths,sids);
            handler.setPathToSIDMap(pathToSIDMap);
        end

    end

end

