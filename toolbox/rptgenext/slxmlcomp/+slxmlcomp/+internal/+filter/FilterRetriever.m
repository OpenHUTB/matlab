classdef FilterRetriever<handle



    properties(Constant,Access=private)
        FilterStates=slxmlcomp.internal.filter.FilterRetriever.getFilterStates();
    end

    methods(Static,Access=public)

        function filterState=retrieve(name)
            import slxmlcomp.internal.filter.FilterRetriever;

            if~FilterRetriever.FilterStates.isKey(name)
                error(...
                'SimulinkXMLComparison:filter:IllegalFilterState',...
                'Illegal ComparisonFilterState: %s',name...
                );
            end

            filterState=FilterRetriever.FilterStates(name);
        end

        function supportedFilters=getSupportedFilters()
            import slxmlcomp.internal.filter.FilterRetriever;
            supportedFilters=FilterRetriever.FilterStates.keys;
        end

    end

    methods(Static,Access=private)

        function states=getFilterStates()
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.matlab.FilterStateUtils;
            jStates=FilterStateUtils.getFilterStates();
            states=containers.Map();
            for i=0:jStates.size()-1
                name=char(jStates.get(i).getName());
                value=jStates.get(i).getFilterState();
                states(name)=value;
            end
        end

    end

    methods(Access=private)

        function obj=FilterRetriever()
        end

    end

end