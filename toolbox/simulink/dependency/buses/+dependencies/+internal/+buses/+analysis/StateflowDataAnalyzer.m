classdef StateflowDataAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        DataType="StateflowDataType";
    end

    methods
        function this=StateflowDataAnalyzer()
            import dependencies.internal.analysis.simulink.queries.StateflowQuery
            queries.data=StateflowQuery.createDataQuery("dataType");
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            deps=dependencies.internal.graph.Dependency.empty(1,0);


            if length(handler.Analyzers.Bus.BusNode.Location)>1
                return;
            end

            busNode=handler.Analyzers.Bus.BusNode;

            dataTypes=[matches.data.Value];
            name=busNode.Location{end};
            pattern=dependencies.internal.buses.util.BusTypes.getBusDataTypePattern(name);
            idx=dependencies.internal.buses.util.regexpmatch(dataTypes,pattern);

            for match=matches.data(idx)
                component=match.createComponent();
                type=dependencies.internal.graph.Type(this.DataType);
                deps(end+1)=createBusDependency(component,busNode,type);%#ok<AGROW>
            end
        end

    end
end
