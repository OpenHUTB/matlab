classdef CodeInParamAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Access=private,Constant)
        Types=dependencies.internal.buses.util.BusTypes.CodeInParam;
    end

    methods

        function this=CodeInParamAnalyzer()
            for type=this.Types
                this.addQueryBasedOnType(type);
            end
        end

        function deps=analyze(this,handler,fileNode,matches)
            import dependencies.internal.buses.util.CodeUtils.codeMatch
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;

            busNode=handler.Analyzers.Bus.BusNode;
            busElement=busNode.Location{end};

            for n=1:length(this.Types)
                code={matches{2*n-1}.Value};
                blocks={matches{2*n}.Value};
                typeStr=this.Types(n).depType;

                for m=1:length(code)
                    if codeMatch(code{m},busElement)
                        blockComp=Component.createBlock(fileNode,blocks{m},handler.getSID(blocks{m}));
                        type=dependencies.internal.graph.Type(typeStr);
                        deps(end+1)=createBusDependency(...
                        blockComp,busNode,type);%#ok<AGROW>
                    end
                end
            end
        end

    end

    methods(Access='private')
        function addQueryBasedOnType(this,type)
            this.addQueryToTable(type.blockType,type.param,type.paramQueryVersions);

            if(~ismissing(type.oldParam))
                this.addQueryToTable(type.blockType,type.oldParam,type.oldParamQueryVersions);
            end
        end

        function addQueryToTable(this,blockType,param,versions)
            query=strcat("//System/Block[BlockType='",blockType,"']/",param);
            code=Simulink.loadsave.Query(query);
            block=Simulink.loadsave.Query(query);
            block.Modifier=Simulink.loadsave.Modifier.BlockPath;
            for query=[code,block]
                this.addQueries(query,{'any'},versions(1),versions(2));
            end
        end
    end
end
