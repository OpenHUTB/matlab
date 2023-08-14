classdef SimulinkModelComparison<comparisons.internal.FileComparison










    methods(Hidden,Access=public)

        function obj=SimulinkModelComparison(javaDriver)
            obj@comparisons.internal.FileComparison(javaDriver);
        end

    end

    methods(Access=public)

        function report=publish(comparison,varargin)
            import slxmlcomp.internal.api.PublishInputParser;
            import slxmlcomp.internal.api.ComparisonPublisher;
            import comparisons.internal.util.process;
            import comparisons.internal.util.APIUtils;
            try
                parser=PublishInputParser(comparison.JavaDriver);
                options=parser.parse(varargin{:});
                publisher=ComparisonPublisher(comparison.JavaDriver);
                report=process(@()publisher.publish(options));
            catch exception
                APIUtils.handleExceptionCallStack(exception);
            end
        end

        function filter(comparison,filter)
            import slxmlcomp.internal.api.FilterInputParser;
            import slxmlcomp.internal.filter.FilterRetriever;
            import comparisons.internal.util.process;
            import comparisons.internal.util.APIUtils;
            try
                parser=FilterInputParser(...
                FilterRetriever.getSupportedFilters()...
                );
                filterName=parser.parse(filter);
                process(@()comparison.filterComparison(filterName));
            catch exception
                APIUtils.handleExceptionCallStack(exception);
            end
        end

    end

    methods(Access=private)

        function filterComparison(this,name)
            import slxmlcomp.internal.filter.FilterRetriever;
            definition=FilterRetriever.retrieve(name);
            this.JavaDriver.filterComparison(definition);
        end

    end

end
