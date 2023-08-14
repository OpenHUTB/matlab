classdef SignalNameAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        Type="SignalName";
    end

    methods(Access=public)
        function this=SignalNameAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery
            queries.portNames=BlockParameterQuery.createPortParameterQuery("Name",Name="*",Index="*");
            queries.portNumbers=BlockParameterQuery.createPortParameterQuery("Index",Name="*",Index="*");
            queries.charts=BlockParameterQuery.createParameterQuery("Name",BlockType="S-Function",FunctionName="sf_sfun");
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            deps=dependencies.internal.graph.Dependency.empty(1,0);

            busNode=handler.Analyzers.Bus.BusNode;
            signalName=busNode.Location{end};

            isBusPort=string(matches.portNames.Value)==signalName;
            isChart=startsWith(matches.portNames.BlockPath,matches.charts.BlockPath);

            for n=find(isBusPort&~isChart)
                portPath=matches.portNumbers.BlockPath{n}+":"+matches.portNumbers.Value{n};
                sid=handler.getSID(matches.portNumbers.BlockPath{n});
                component=dependencies.internal.graph.Component.createBlock(node,portPath,sid);
                type=dependencies.internal.graph.Type(this.Type);
                deps(end+1)=createBusDependency(component,busNode,type);%#ok<AGROW>
            end
        end
    end
end
