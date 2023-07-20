classdef ExternalToolboxAnalysisCustomization<dependencies.internal.engine.AnalysisCustomization




    properties(Constant)
        Key="AnalyzeExternalToolboxes";
        Name=string(message("MATLAB:dependency:analysis:AnalyzeExternalToolboxes"));
        DefaultEnabled=false;
    end

    methods(Static)
        function[analyzers,filters]=apply(nodes,analyzers,filters,enabled)
            import dependencies.internal.analysis.toolbox.ToolboxAnalyzer
            import dependencies.internal.engine.filters.analyzeWithin
            import dependencies.internal.engine.filters.analyzeNodes

            project=matlab.project.rootProject;
            if isempty(project)
                filters(end+1)=analyzeNodes(nodes)|ToolboxAnalyzer.analyzeToolboxes(enabled);
            else
                roots=[project.RootFolder,project.listAllProjectReferences().File];
                filters(end+1)=analyzeNodes(nodes)|analyzeWithin(roots)|ToolboxAnalyzer.analyzeToolboxes(enabled);
            end
        end
    end

end
