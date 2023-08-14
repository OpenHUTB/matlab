classdef InitialValueAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        Types=dependencies.internal.buses.util.BusTypes.InitValue;
    end

    methods(Access=public)
        function this=InitialValueAnalyzer()
            for n=1:length(this.Types)
                type=this.Types(n);
                baseQuery=strcat("//System/Block[BlockType='",type.blockType,...
                "' and ",type.param,"=* and OutDataTypeStr=*]");
                outDataType=Simulink.loadsave.Query(strcat(baseQuery,"/OutDataTypeStr"));
                code=Simulink.loadsave.Query(strcat(baseQuery,"/",type.param));
                block=Simulink.loadsave.Query(baseQuery);
                block.Modifier=Simulink.loadsave.Modifier.BlockPath;
                this.addQueries([outDataType;code;block]);
            end
        end

        function deps=analyze(this,handler,fileNode,matches)
            import dependencies.internal.buses.util.BusTypes

            busNode=handler.Analyzers.Bus.BusNode;
            busTypePattern=BusTypes.getBusDataTypePattern(busNode.Location{1});

            deps=dependencies.internal.graph.Dependency.empty;
            for n=1:length(this.Types)
                deps=[deps,i_analyze(handler,busNode,fileNode,busTypePattern,...
                matches{3*n-2},matches{3*n-1},matches{3*n},...
                this.Types(n).depType)];%#ok<AGROW>
            end

        end
    end
end

function deps=i_analyze(handler,busNode,fileNode,busTypePattern,outDataTypeMatches,...
    codeMatches,blockMatches,typeStr)
    import dependencies.internal.buses.util.CodeUtils;
    import dependencies.internal.graph.Component;
    deps=dependencies.internal.graph.Dependency.empty;

    busElement=busNode.Location{end};

    for n=1:length(outDataTypeMatches)
        if~isempty(regexp(outDataTypeMatches(n).Value,busTypePattern,"once"))&&...
            CodeUtils.codeMatch(codeMatches(n).Value,busElement)
            blockPath=blockMatches(n).Value;
            sid=handler.getSID(blockPath);
            blockComp=Component.createBlock(fileNode,blockPath,sid);
            type=dependencies.internal.graph.Type(typeStr);
            deps(end+1)=createBusDependency(...
            blockComp,busNode,type);%#ok<AGROW>
        end
    end
end
