classdef StateflowStatesAndTransitionsAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        StateType="StateflowState";
        TransitionType="StateflowTransition";
    end

    methods
        function this=StateflowStatesAndTransitionsAnalyzer()
            import dependencies.internal.analysis.simulink.queries.StateflowQuery
            queries.states=StateflowQuery.createStateQuery("labelString");
            queries.transitions=StateflowQuery.createTransitionQuery("labelString");
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,~,matches)
            busNode=handler.Analyzers.Bus.BusNode;

            if length(busNode.Location)>1
                patStart="\.";
            else
                patStart="(^|[^\w\.])";
            end
            name=busNode.Location{end};
            pattern=strcat(patStart,name,"([^\w:]|$)");

            deps=[
            i_filterAndCreatePaths(busNode,matches.states,pattern,this.StateType)
            i_filterAndCreatePaths(busNode,matches.transitions,pattern,this.TransitionType)
            ];
        end
    end

end

function deps=i_filterAndCreatePaths(busNode,matches,pattern,type)
    deps=dependencies.internal.graph.Dependency.empty(1,0);
    type=dependencies.internal.graph.Type(type);

    if isempty(matches)
        return;
    end

    idx=dependencies.internal.buses.util.regexpmatch([matches.Value],pattern);
    for match=matches(idx)
        component=match.createComponent();
        deps(end+1)=createBusDependency(component,busNode,type);%#ok<AGROW>
    end
end
