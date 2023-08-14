classdef SymbolSeparatedParamAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        Types=dependencies.internal.buses.util.BusTypes.SymbolSeparated;
    end

    methods(Access=public)
        function this=SymbolSeparatedParamAnalyzer()
            for n=1:length(this.Types)
                type=this.Types(n);
                query=strcat("//System/Block[BlockType='",type.blockType,"']/",type.param);
                q1=Simulink.loadsave.Query(query);
                q2=Simulink.loadsave.Query(query);
                q2.Modifier=Simulink.loadsave.Modifier.BlockPath;
                this.addQueries([q1,q2]);
            end
        end

        function deps=analyze(this,handler,fileNode,matches)
            deps=dependencies.internal.graph.Dependency.empty;

            busNode=handler.Analyzers.Bus.BusNode;
            for n=1:length(this.Types)
                type=this.Types(n);
                deps=[deps,i_analyze(handler,busNode,fileNode,matches{2*n-1},matches{2*n},...
                type.symbol,type.depType)];%#ok<AGROW>
            end
        end
    end
end

function deps=i_analyze(handler,busNode,fileNode,signalMatches,pathMatches,symbol,typeStr)
    import dependencies.internal.graph.Component;
    import dependencies.internal.graph.Dependency;
    import dependencies.internal.graph.Type;

    deps=Dependency.empty;
    type=Type(typeStr);
    signalType=Type("Signal");

    busNameOrElementPattern=strcat(...
    "^'?(?:\w+\.)*",busNode.Location(end),"(?:\.\w+)*'?$");

    for i=1:length(signalMatches)
        outputSignals=string(split(signalMatches(i).Value,symbol));
        blockPath=pathMatches(i).Value;
        blockComp=Component.createBlock(fileNode,blockPath,handler.getSID(blockPath));

        matchingSignals=reshape(~cellfun(@isempty,regexp(outputSignals,...
        busNameOrElementPattern,"forceCellOutput")),1,[]);
        for n=find(matchingSignals)
            signal=Component(busNode,outputSignals(n),signalType,0,"","","");
            deps(end+1)=createBusDependency(...
            blockComp,busNode,type,signal);%#ok<AGROW>
        end
    end
end
