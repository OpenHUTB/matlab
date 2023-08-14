classdef StateflowMATLABFunctionsAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        MATLABFcnType="MATLABFcn";
        StateflowMATLABFcnType="StateflowMATLABFcn";
    end

    methods
        function this=StateflowMATLABFunctionsAnalyzer()
            import dependencies.internal.analysis.simulink.queries.StateflowQuery
            import dependencies.internal.analysis.simulink.queries.StateflowChartQuery

            queries.eml=StateflowQuery.createStateQuery("eml/script");
            queries.mlfunc=StateflowChartQuery.createChartQuery(type="EML_CHART");

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,~,matches)
            import dependencies.internal.buses.util.CodeUtils;

            deps=dependencies.internal.graph.Dependency.empty(1,0);


            if isempty(matches.eml)
                return;
            end

            mlType=dependencies.internal.graph.Type(this.MATLABFcnType);
            sfType=dependencies.internal.graph.Type(this.StateflowMATLABFcnType);

            busNode=handler.Analyzers.Bus.BusNode;
            name=busNode.Location{end};


            emlChartIDs=string([matches.eml.ChartID]);
            simChartIDs=string([matches.mlfunc.ChartID]);
            simIdx=ismember(emlChartIDs,simChartIDs);


            for eml=matches.eml(simIdx)
                if CodeUtils.searchCode(eml.Value,name)
                    component=eml.createComponent();
                    deps(end+1)=createBusDependency(component,busNode,mlType);%#ok<AGROW>
                end
            end


            for eml=matches.eml(~simIdx)
                if CodeUtils.searchCode(eml.Value,name)
                    component=eml.createComponent();
                    deps(end+1)=createBusDependency(component,busNode,sfType);%#ok<AGROW>
                end
            end
        end
    end
end
