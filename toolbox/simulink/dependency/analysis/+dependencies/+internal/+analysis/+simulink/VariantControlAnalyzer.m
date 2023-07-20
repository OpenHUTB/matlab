classdef VariantControlAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        VariantControlType='VariantControl';
    end

    methods

        function this=VariantControlAnalyzer()

            mdlrefParam=Simulink.loadsave.Query('//System/Block[BlockType="ModelReference" and Variant="on"]/Array[PropName="Variants"]/MATStruct/Name');
            mdlrefBlock=Simulink.loadsave.Query('//System/Block[BlockType="ModelReference" and Variant="on"]/Array[PropName="Variants"]/MATStruct/Name');
            mdlrefBlock.Modifier=Simulink.loadsave.Modifier.BlockPath;


            subsysParam=Simulink.loadsave.Query('//System/Block[BlockType="SubSystem" and Variant="on"]/System/Block[BlockType="SubSystem"]/VariantControl');
            subsysBlock=Simulink.loadsave.Query('//System/Block[BlockType="SubSystem" and Variant="on"]/System/Block[BlockType="SubSystem"]/VariantControl');
            subsysBlock.Modifier=Simulink.loadsave.Modifier.BlockPath;


            variantAssemblyParam=Simulink.loadsave.Query('//System/Block[BlockType="SubSystem" and Variant="on"]/VariantChoicesSpecifier');
            variantAssemblyBlock=Simulink.loadsave.Query('//System/Block[BlockType="SubSystem" and Variant="on"]/VariantChoicesSpecifier');
            variantAssemblyBlock.Modifier=Simulink.loadsave.Modifier.BlockPath;


            srcParamSlx=Simulink.loadsave.Query('//System/Block/VariantControls/Ref');
            srcBlockSlx=Simulink.loadsave.Query('//System/Block/VariantControls/Ref');
            srcBlockSlx.Modifier=Simulink.loadsave.Modifier.BlockPath;


            srcParamMdl=Simulink.loadsave.Query('//System/Block/VariantControls');
            srcBlockMdl=Simulink.loadsave.Query('//System/Block/VariantControls');
            srcBlockMdl.Modifier=Simulink.loadsave.Modifier.BlockPath;


            override=Simulink.loadsave.Query('//System/Block/OverrideUsingVariant');
            overrideBlock=Simulink.loadsave.Query('//System/Block/OverrideUsingVariant');
            overrideBlock.Modifier=Simulink.loadsave.Modifier.BlockPath;


            labelOverride=Simulink.loadsave.Query('//System/Block/LabelModeActiveChoice');
            labelOverrideBlock=Simulink.loadsave.Query('//System/Block/LabelModeActiveChoice');
            labelOverrideBlock.Modifier=Simulink.loadsave.Modifier.BlockPath;


            this.addQueries(...
            [mdlrefParam;mdlrefBlock]);
            this.addQueries(...
            [subsysParam;subsysBlock]);
            this.addQueries(...
            [variantAssemblyParam;variantAssemblyBlock]);
            this.addQueries(...
            [srcParamSlx;srcBlockSlx;srcParamMdl;srcBlockMdl],...
            {'slx';'slx';'mdl';'mdl'});
            this.addQueries(...
            [override;overrideBlock;labelOverride;labelOverrideBlock]);
        end

        function deps=analyze(this,handler,node,matches)

            emptyOverride=cellfun('isempty',{matches{9}.Value,matches{11}.Value});
            overridden={matches{10}.Value,matches{12}.Value};
            overridden(emptyOverride)=[];


            mdlrefParams={matches{1}.Value};
            mdlrefBlocks={matches{2}.Value};
            mdlIdx=~ismember(mdlrefBlocks,overridden);
            deps=this.analyzeExpressions(handler,node,mdlrefParams(mdlIdx),mdlrefBlocks(mdlIdx));


            subsysParams={matches{3}.Value};
            subsysBlocks={matches{4}.Value};
            subsysRoots=regexp(subsysBlocks,'^.*(?=(?<!/)/(?!/))','match');
            subsysRoots=[subsysRoots{:}];
            if~isempty(subsysRoots)
                subsysIdx=~ismember(subsysRoots,overridden);
                deps=[deps,this.analyzeExpressions(handler,node,subsysParams(subsysIdx),subsysRoots(subsysIdx))];
            end


            variantAssemblyParam={matches{5}.Value};
            variantAssemblyBlock={matches{6}.Value};
            deps=[deps,this.analyzeExpressions(handler,node,variantAssemblyParam,variantAssemblyBlock)];


            dataTags={matches{7}.Value};
            srcBlocks={matches{8}.Value};
            srcIdx=~ismember(srcBlocks,overridden);
            for n=find(srcIdx)
                if handler.ModelInfo.IsSLX
                    tag=dataTags{n}(10:end);
                else
                    tag=dataTags{n};
                end

                data=dependencies.internal.analysis.simulink.readMxData(handler,tag);
                newDeps=this.analyzeExpressions(handler,node,data,repmat(srcBlocks(n),size(data)));

                if~isempty(newDeps)
                    deps=[deps,newDeps];%#ok<AGROW>
                end
            end
        end

    end

    methods(Access=private)

        function deps=analyzeExpressions(this,handler,node,params,blocks)
            import dependencies.internal.analysis.matlab.Scope;
            import dependencies.internal.graph.Component;

            deps=dependencies.internal.graph.Dependency.empty;

            for n=1:length(params)
                param=params{n};
                block=blocks{n};

                blkWorkspace=handler.getWorkspace(block);
                if Simulink.variant.keywords.isValidVariantKeyword(param)...
                    ||blkWorkspace.isVariable(param,Scope.File)
                    continue;
                end

                sid=handler.getSID(block);
                factory=dependencies.internal.analysis.DependencyFactory(...
                handler,Component.createBlock(node,block,sid),this.VariantControlType);
                factory.CreateUnresolved=~handler.ModelInfo.IsLibrary;

                newDeps=handler.Analyzers.MATLAB.analyze(param,factory,blkWorkspace);

                if~isempty(newDeps)
                    deps=[deps,newDeps];%#ok<AGROW>
                end
            end
        end

    end

end


