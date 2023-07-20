classdef BusPortAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        Types=dependencies.internal.buses.util.BusTypes.BusPortTypes;
    end

    methods(Access=public)
        function this=BusPortAnalyzer()
            for n=1:length(this.Types)
                blockType=this.Types(n).blockType;

                query=strcat("//System/Block[BlockType='",blockType,...
                "']/List[ListType='InterfaceData']/Element");
                value=Simulink.loadsave.Query(query);
                path=Simulink.loadsave.Query(query);
                path.Modifier=Simulink.loadsave.Modifier.BlockPath;
                this.addQueries([value,path]);
            end
        end

        function deps=analyze(this,handler,fileNode,matches)
            deps=dependencies.internal.graph.Dependency.empty;


            if length(handler.Analyzers.Bus.BusNode.Location)==1
                return;
            end

            busNode=handler.Analyzers.Bus.BusNode;
            for n=1:length(this.Types)
                type=this.Types(n).refElementType;
                deps=[deps,i_analyze(handler,busNode,fileNode,matches{2*n-1},...
                matches{2*n},type)];%#ok<AGROW>
            end
        end
    end
end

function deps=i_analyze(handler,busNode,fileNode,nameMatches,pathMatches,typeStr)
    names=i_getStrValues(nameMatches);
    paths=i_getStrValues(pathMatches);

    element=busNode.Location{end};
    matchElementsAndExtractFromNameToElement=strcat("^((?:\w+\.)*",element,")(?:\.|$)");
    allBusTokens=regexp(names,matchElementsAndExtractFromNameToElement,"tokens");

    busNames=strings(1,length(allBusTokens));
    for n=1:length(allBusTokens)
        tokens=allBusTokens{n};
        if~isempty(tokens)
            busNames(n)=tokens{1};
        end
    end

    deps=dependencies.internal.graph.Dependency.empty(1,0);
    for n=find(busNames~="")
        upComp=dependencies.internal.graph.Component.createBlock(fileNode,paths(n),handler.getSID(paths(n)));
        type=dependencies.internal.graph.Type(typeStr);
        deps(end+1)=createBusDependency(upComp,busNode,type,busNames(n));%#ok<AGROW>
    end
end

function values=i_getStrValues(matches)
    values=string({matches.Value});
end
