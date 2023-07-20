classdef BlockVariantBuilder<handle





    properties(Access=protected)
        ModelName;
        ChangeLogger autosar.updater.ChangeLogger
        AddedBlocks;
        BlockToVariantMap containers.Map
    end

    methods
        function this=BlockVariantBuilder(modelName,changeLogger)
            this.ModelName=modelName;
            this.ChangeLogger=changeLogger;
            this.AddedBlocks=[];
            this.BlockToVariantMap=containers.Map();
        end

        function blocks=getAddedBlocks(this)
            blocks=this.AddedBlocks;
        end

        function variantPath=getVariantBlock(this,blockPath)
            if this.BlockToVariantMap.isKey(blockPath)
                variantPath=this.BlockToVariantMap(blockPath);
            else
                variantPath=[];
            end
        end

        function variantPath=addVariantForBlock(this,blockPath,blockType,m3iVariationPoint,slSystemName)











            variantPath=[];

            if isempty(m3iVariationPoint)
                return;
            end

            if nargin<5
                slSystemName=this.getParentForBlock(blockPath);
            end

            if~m3iVariationPoint.PostBuildVariantCondition.isEmpty()
                if~slfeature('AUTOSARPostBuildVariant')
                    DAStudio.error('autosarstandard:importer:UnsupportedPostBuildBindingTime',m3iVariationPoint.Name);
                end
                if m3iVariationPoint.Condition.isvalid()
                    DAStudio.error('autosarstandard:importer:VpMixedBindTime',m3iVariationPoint.Name);
                end
                bindingTime='PostBuild';
            else
                if~m3iVariationPoint.Condition.isvalid()

                    return;
                end
                bindingTime=m3iVariationPoint.Condition.BindingTime.toString;
            end


            switch bindingTime
            case 'PreCompileTime'
                variantActivationTime='code compile';
            case 'CodeGenerationTime'
                warnId='autosarstandard:importer:unsupportedCodeGenTimeBindingTime';
                warnParams={getfullname(blockPath)};
                messageStream=autosar.mm.util.MessageStreamHandler.instance();
                messageStream.createWarning(warnId,warnParams,...
                blockPath,'modelImport');
                variantActivationTime='code compile';
            case 'PostBuild'
                variantActivationTime='startup';
            otherwise
                warnId='autosarstandard:importer:unsupportedBindingTime';
                warnParams={m3iVariationPoint.Condition.BindingTime.toString,getfullname(blockPath)};
                messageStream=autosar.mm.util.MessageStreamHandler.instance();
                messageStream.createWarning(warnId,warnParams,...
                blockPath,'modelImport');
                return;
            end

            blockBasePath=autosar.mm.mm2sl.BlockVariantBuilder.removeModelName(...
            slSystemName,blockPath);

            blockPos=get_param(blockPath,'Position');
            centerY=mean([blockPos(2),blockPos(4)]);

            if strcmp(blockType,'Inport')
                variantBlockType='VariantSource';
                variantBlockXOffset=50;
            else
                variantBlockType='VariantSink';
                variantBlockXOffset=-100;
            end

            defaultVsrcPos=get_param(['built-in/',variantBlockType],'Position');
            variantBlockLeft=blockPos(3)+variantBlockXOffset;
            variantBlockWidth=defaultVsrcPos(3)-defaultVsrcPos(1);
            variantBlockHeight=defaultVsrcPos(4)-defaultVsrcPos(2);
            position=[variantBlockLeft,centerY-(variantBlockHeight/2),...
            variantBlockLeft+variantBlockWidth,centerY+(variantBlockHeight/2)];

            blockName=get_param(blockPath,'Name');
            variantName=sprintf('%s_%s',blockName,m3iVariationPoint.Name);
            maxShortNameLength=get_param(this.ModelName,'AutosarMaxShortNameLength');
            variantName=arxml.arxml_private('p_create_aridentifier',...
            variantName,...
            maxShortNameLength);
            blkHandle=add_block(['built-in/',variantBlockType],...
            [getfullname(slSystemName),'/',variantName],...
            'MakeNameUnique','on',...
            'Position',position);
            variantPath=getfullname(blkHandle);
            this.AddedBlocks{end+1}=variantPath;


            this.ChangeLogger.logAddition('Automatic',[variantBlockType,' block'],variantPath);

            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
            variantPath,'VariantActivationTime',variantActivationTime);
            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
            variantPath,'AllowZeroVariantControls','on');

            variantBasePath=autosar.mm.mm2sl.BlockVariantBuilder.removeModelName(...
            slSystemName,variantPath);
            set_param(variantPath,'VariantControls',{m3iVariationPoint.Name});
            set_param(variantPath,'ShowName','off');

            if strcmp(get_param(blockPath,'BlockType'),'Inport')&&strcmp(get_param(blockPath,'OutputFunctionCall'),'on')

                set_param(variantPath,'OutputFunctionCall','on');
            end

            if strcmp(blockType,'Inport')
                autosar.mm.mm2sl.layout.LayoutHelper.addLine(slSystemName,...
                [blockBasePath,'/1'],[variantBasePath,'/1']);
            else
                autosar.mm.mm2sl.layout.LayoutHelper.addLine(slSystemName,...
                [variantBasePath,'/1'],[blockBasePath,'/1']);
            end

            if isempty(this.BlockToVariantMap)


                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                this.ModelName,'SaveOutput','Off');
            end
            this.BlockToVariantMap(blockPath)=variantPath;
        end
    end

    methods(Static,Access=private)
        function path=removeModelName(modelName,path)
            path=regexprep(path,['^',modelName,'/'],'');
        end

        function parentSystem=getParentForBlock(blockPath)
            blockPathSplit=strsplit(getfullname(blockPath),'/');
            parentSystem=strjoin(blockPathSplit(1:end-1),'/');
        end
    end
end


