classdef DataDictionaryAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        DataDictionaryType='DataDictionary';
    end

    methods

        function this=DataDictionaryAnalyzer()
            import dependencies.internal.analysis.simulink.queries.MF0Query
            import dependencies.internal.analysis.simulink.queries.ModelParameterQuery
            queries.DataDictionary=ModelParameterQuery("DataDictionary");
            queries.LibDataDictionary=MF0Query("BrokerConfig","ExplicitExternalSources");
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            deps=dependencies.internal.graph.Dependency.empty;

            dictionaries=[matches.DataDictionary.Value...
            ,arrayfun(@i_extractDictionaryName,matches.LibDataDictionary.Names)];

            for dictionary=dictionaries

                target=handler.Resolver.findFile(node,dictionary,".sldd");
                deps(end+1)=dependencies.internal.graph.Dependency(...
                node,"",target,"",this.DataDictionaryType);%#ok<AGROW>


                if target.Resolved
                    vars=handler.Analyzers.SLDD.getVariables(target.Location{1});
                    handler.ModelWorkspace.addVariables(vars);
                end
            end
        end

    end

end

function ddName=i_extractDictionaryName(ddFullPathWithExtraTokens)
    [~,ddName]=fileparts(ddFullPathWithExtraTokens);
    ddName=ddName+".sldd";
end
