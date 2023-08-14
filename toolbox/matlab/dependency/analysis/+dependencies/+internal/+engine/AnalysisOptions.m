classdef AnalysisOptions




    properties

        Filters(1,:)dependencies.internal.engine.AnalysisFilter=dependencies.internal.engine.AnalysisOptions.createDefaultFilter();

        NodeAnalyzers(1,:)dependencies.internal.analysis.NodeAnalyzer=dependencies.internal.Registry.Instance.NodeAnalyzers;


        SharedAnalyzerFactories(1,:)dependencies.internal.analysis.SharedAnalyzerFactory=dependencies.internal.Registry.Instance.SharedAnalyzerFactories;

        EventHandler(1,1)function_handle=@(Tag,Node,NumRemaining)disp('');

        ExceptionHandler(1,1)function_handle=@(node,exception)disp('');

        WarningHandler(1,1)function_handle=@(node,warning)disp('');

        CancellationPredicate(1,1)function_handle=@false;
    end

    methods(Static)
        function defaultFilter=createDefaultFilter()
            np=dependencies.internal.graph.NodeFilter.wrapNode(@(nodes)true(size(nodes)));
            dp=dependencies.internal.graph.DependencyFilter.wrapDependency(@dependencies.internal.engine.predicates.isOutsideMatlabRoot);
            defaultFilter=dependencies.internal.engine.filters.DelegateFilter(np,dp);
        end
    end
end
