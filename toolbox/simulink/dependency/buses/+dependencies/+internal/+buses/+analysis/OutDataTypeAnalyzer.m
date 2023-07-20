classdef OutDataTypeAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        Types=dependencies.internal.buses.util.BusTypes.OutDataTypeTypes;
    end

    methods(Access=public)
        function this=OutDataTypeAnalyzer()
            for type=this.Types
                dataType=Simulink.loadsave.Query(type.query);
                path=Simulink.loadsave.Query(type.query);
                path.Modifier=Simulink.loadsave.Modifier.BlockPath;
                this.addQueries([dataType,path]);
            end

        end

        function deps=analyze(this,handler,fileNode,matches)
            import dependencies.internal.buses.util.BusTypes;

            deps=dependencies.internal.graph.Dependency.empty;
            busNode=handler.Analyzers.Bus.BusNode;


            if length(busNode.Location)>1
                return;
            end

            pattern=BusTypes.getBusDataTypePattern(busNode.Location{end});

            for n=1:length(this.Types)
                deps=[deps,i_analyze(handler,busNode,fileNode,pattern,...
                matches{2*n-1},matches{2*n},this.Types(n).depType)];%#ok<AGROW>
            end
        end
    end
end

function deps=i_analyze(handler,busNode,fileNode,busTypePattern,dataTypeMatches,pathMatches,typeStr)
    import dependencies.internal.graph.Component;
    import dependencies.internal.graph.Dependency;
    deps=Dependency.empty;
    for i=1:length(dataTypeMatches)
        if~isempty(regexp(dataTypeMatches(i).Value,busTypePattern,"once"))
            blockPath=pathMatches(i).Value;
            sid=handler.getSID(blockPath);
            blockComp=Component.createBlock(fileNode,blockPath,sid);
            type=dependencies.internal.graph.Type(typeStr);
            deps(end+1)=createBusDependency(blockComp,busNode,type);%#ok<AGROW>
        end
    end
end
