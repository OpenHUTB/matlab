classdef SFunctionBuilderAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        SFunctionBuilderType=dependencies.internal.graph.Type("SFunctionBuilder");
    end

    methods

        function this=SFunctionBuilderAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.*

            queries.mdl=createParameterQuery("WizardData",BlockType="S-Function");
            queries.slx=createParameterQuery("WizardData/Ref",BlockType="S-Function");

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            deps=dependencies.internal.graph.Dependency.empty;

            if handler.ModelInfo.IsSLX
                for n=1:numel(matches.slx.Value)
                    tag=matches.slx.Value{n}(10:end);
                    data=dependencies.internal.analysis.simulink.readMxData(handler,tag);
                    deps=[deps,this.analyzeData(handler,node,matches.slx.BlockPath{n},data)];%#ok<AGROW>
                end

            else
                for n=1:numel(matches.mdl.Value)
                    tag=matches.mdl.Value{n};
                    data=dependencies.internal.analysis.simulink.readMxData(handler,tag);
                    deps=[deps,this.analyzeData(handler,node,matches.mdl.BlockPath{n},data)];%#ok<AGROW>
                end
            end
        end

    end

    methods(Access=private)
        function deps=analyzeData(this,handler,node,block,data)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;


            upComp=Component.createBlock(node,block,handler.getSID(block));

            [files,folders]=i_getReferences(data);


            for n=1:length(files)
                target=handler.Resolver.findFile(node,files{n},{});
                deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                upComp,target,this.SFunctionBuilderType);%#ok<AGROW>
            end


            for m=1:numel(folders)
                target=dependencies.internal.graph.Node.createFolderNode(folders{m});
                deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                upComp,target,this.SFunctionBuilderType);%#ok<AGROW>
            end

        end
    end

end



function[files,folders]=i_getReferences(data)
    files={};


    if~isempty(data.LibraryFilesText)
        tmpCell=textscan(data.LibraryFilesText,'%s','delimiter',newline);
        if~isempty(tmpCell)&&iscell(tmpCell)
            files=tmpCell{1};
            files=files(~cellfun('isempty',files))';
        end
    end


    code=[data.IncludeHeadersText,'\n',data.UserCodeText];
    [codefiles,~,folders]=dependencies.internal.analysis.simulink.resolveCustomCode('','','','',code);
    files=[files,codefiles];
end
