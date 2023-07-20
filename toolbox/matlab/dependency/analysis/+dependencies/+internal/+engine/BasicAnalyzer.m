classdef BasicAnalyzer<dependencies.internal.engine.GraphAnalyzer







    methods

        function this=BasicAnalyzer(analyzers)
            if nargin>0
                this.NodeAnalyzers=analyzers;
            end
        end

        function graph=analyze(this,queue)

            options=dependencies.internal.engine.AnalysisOptions;



            if isempty(this.Filters)
                options.Filters=this.makeFilter();
            else
                options.Filters=this.Filters;
            end
            options.NodeAnalyzers=this.NodeAnalyzers;
            options.EventHandler=@this.handleEvent;
            options.WarningHandler=this.WarningHandler;
            options.ExceptionHandler=@this.handleException;
            options.CancellationPredicate=this.CancelFunction;


            result=dependencies.internal.engine.analyze(queue,options);



            graph=this.GraphFactory();
            graph.addNode(result.Nodes);
            graph.addDependency(result.Dependencies);
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

        function filter=makeFilter(this)
            np=dependencies.internal.graph.NodeFilter.wrapNode(this.NodePredicate);
            dp=dependencies.internal.graph.DependencyFilter.wrapDependency(this.DependencyPredicate);
            filter=dependencies.internal.engine.filters.DelegateFilter(np,dp);
        end

        function handleException(this,node,exception)
            me=dependencies.internal.util.wrapException(...
            exception,'MATLAB:dependency:analysis:AnalysisError',node.ID);
            this.ExceptionHandler(node,me);
        end

    end

end
