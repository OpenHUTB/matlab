classdef DataDictionaryNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        DataDictionaryRequirementType=dependencies.internal.graph.Type("RequirementInfo,DataDictionary");
        Extensions=".sldd";
    end

    methods

        function deps=analyze(this,handler,node)
            import dependencies.internal.analysis.simulink.DataDictionaryAnalyzer;
            import dependencies.internal.util.resolveExternalRequirementLinks;

            deps=dependencies.internal.graph.Dependency.empty;

            targets=handler.Analyzers.SLDD.getReferences(node.Location{1});
            for n=1:length(targets)
                deps(end+1)=dependencies.internal.graph.Dependency(...
                node,'',targets(n),'',DataDictionaryAnalyzer.DataDictionaryType);%#ok<AGROW>
            end

            reqDeps=resolveExternalRequirementLinks(handler,node,this.DataDictionaryRequirementType);
            if~isempty(reqDeps)
                deps=[deps,reqDeps];
            end
        end

    end

end
