classdef ToolboxBlocksAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        SourceBlockType='SourceBlock';
        Toolboxes={...
        {'dspvision/From Multimedia File','inputFilename','SourceBlock,MultimediaFile'},...
        {'visionsources/From Multimedia File','inputFilename','SourceBlock,MultimediaFile'},...
        {'visionsources/Image From File','FileName','SourceBlock,ImageFile'},...
        {'visionsources/Read Binary File','FileName','SourceBlock,BinaryFile'},...
        {'vrlib/VR Sink','WorldFileName','SourceBlock,VRWorldFile'},...
        {'vrlib/VR Source','WorldFileName','SourceBlock,VRWorldFile'},...
        {'vrlib/VR To Video','WorldFileName','SourceBlock,VRWorldFile'}...
        ,{'dspsrcs4/From Multimedia File','inputFilename','SourceBlock,MultimediaFile'},...
        {'vipsrcs/From Multimedia File','inputFilename','SourceBlock,MultimediaFile'},...
        {'vipsrcs/Image From File','FileName','SourceBlock,ImageFile'},...
        {'vipsrcs/Read Binary File','FileName','SourceBlock,BinaryFile'},...
        }
    end

    methods

        function this=ToolboxBlocksAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createInstanceDataParameterQuery
            for n=1:length(this.Toolboxes)
                block=this.Toolboxes{n}{1};
                param=this.Toolboxes{n}{2};
                queries.("q"+n)=createInstanceDataParameterQuery(param,"SourceBlock",block);
            end
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty(1,0);

            toolbox=1;
            matchesNames=string(fieldnames(matches)');

            for name=matchesNames
                currentMatch=matches.(name);
                for m=1:length(currentMatch.Value)
                    filename=currentMatch.Value{m};
                    blockPath=currentMatch.BlockPath{m};
                    sid=handler.getSID(blockPath);
                    block=Component.createBlock(node,blockPath,sid);
                    type=dependencies.internal.graph.Type(this.Toolboxes{toolbox}{3});

                    target=handler.Resolver.findFile(node,filename,{});
                    deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                    block,target,type);%#ok<AGROW>
                end

                toolbox=toolbox+1;
            end
        end

    end

end
