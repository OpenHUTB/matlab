classdef BusAnalyzer<dependencies.internal.engine.GraphAnalyzer




    properties(SetAccess=immutable)
        BusNode(1,1);
    end

    methods

        function this=BusAnalyzer(node,analyzers)
            this.BusNode=node;

            if nargin>1
                this.NodeAnalyzers=analyzers;
            else
                this.NodeAnalyzers=dependencies.internal.buses.BusRegistry.Instance.NodeAnalyzers;
            end

            toAnalyze=dependencies.internal.graph.NodeFilter.nodeType(["File","TestHarness","BaseWorkspace"]);
            this.Filters=dependencies.internal.engine.filters.DelegateFilter(toAnalyze);
        end

        function graph=analyze(this,nodes)

            options=dependencies.internal.engine.AnalysisOptions();



            options.Filters=this.Filters;
            options.NodeAnalyzers=this.NodeAnalyzers;
            options.SharedAnalyzerFactories(end+1)=dependencies.internal.buses.BusSharedAnalyzerFactory(this.BusNode);
            options.EventHandler=@this.handleEvent;
            options.WarningHandler=this.WarningHandler;
            options.ExceptionHandler=@this.handleException;
            options.CancellationPredicate=this.CancelFunction;

            result=dependencies.internal.engine.analyze(nodes,options);



            filter=dependencies.internal.graph.DependencyFilter.hasRelationship("Bus");
            graph=this.GraphFactory();
            graph.addNode(result.Nodes);
            graph.addDependency(filter.filter(result.Dependencies));
            graph=graph.create();
        end

    end

    methods(Access=private)
        function handleEvent(this,eventTag,node,numRemaining)
            if strcmp(eventTag,'AnalyzingNode')
                eventData=dependencies.internal.engine.events.AnalyzingNodeEvent(node,numRemaining);
                this.notify(eventTag,eventData);
            else
                this.notify(eventTag);
            end

        end

        function handleException(this,node,exception)
            me=dependencies.internal.util.wrapException(...
            exception,'MATLAB:dependency:analysis:AnalysisError',node.ID);
            this.ExceptionHandler(node,me);
        end

    end
end
