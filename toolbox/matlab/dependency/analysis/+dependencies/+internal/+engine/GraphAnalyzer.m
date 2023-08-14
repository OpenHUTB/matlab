classdef(Abstract)GraphAnalyzer<handle




    properties

        NodeAnalyzers(:,1)dependencies.internal.analysis.NodeAnalyzer=dependencies.internal.Registry.Instance.NodeAnalyzers;

        NodePredicate(1,1)function_handle=@(nodes)true(size(nodes));

        DependencyPredicate(1,1)function_handle=@dependencies.internal.engine.predicates.isOutsideMatlabRoot;

        Filters(1,:)dependencies.internal.engine.AnalysisFilter=dependencies.internal.engine.AnalysisFilter.empty;

        CancelFunction(1,1)function_handle=@false;

        WarningHandler(1,1)function_handle=@(node,warning)disp('');

        ExceptionHandler(1,1)function_handle=@(node,exception)disp('');

        GraphFactory(1,1)function_handle=@dependencies.internal.graph.MutableGraph;
    end

    events

        AnalysisStarted;

        AnalyzingNode;

        AnalysisFinishing;

        AnalysisFinished;

        AnalysisCancelled;
    end

    methods(Abstract)

        graph=analyze(this,nodes);
    end

end
