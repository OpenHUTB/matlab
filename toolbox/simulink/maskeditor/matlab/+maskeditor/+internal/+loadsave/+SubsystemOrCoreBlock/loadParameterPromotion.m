classdef loadParameterPromotion<handle



    properties(SetAccess=private,GetAccess=public)
        m_MEInstance;

        m_Context;
        m_MF0Model;
        m_MEData;

        m_Lookunder;

        m_PromotableParameters;
        m_WidgetsPropertyData;
        m_filesep='/';
        m_PromotableRowsArray;
    end

    properties(Constant)
        m_PROMOTE_TO_SELF=0;
        m_PROMOTE_TO_SUBSYSTEM=1;
        m_PROMOTE_TO_MASK_ON_MASK=2;
        m_PROMOTE_TO_MODEL=3;

        ConfigConstants=maskeditor.internal.loadsave.ConfigConstants();
    end

    methods(Access=public)

        function obj=loadParameterPromotion(aMEInstance,args)
            obj.m_MEInstance=aMEInstance;

            obj.m_Context=aMEInstance.m_Context;
            obj.m_MF0Model=aMEInstance.m_MF0Model;
            obj.m_MEData=aMEInstance.m_MEData;

            configFileKey=obj.ConfigConstants.WIDGET_PROPERTIES;
            obj.m_WidgetsPropertyData=jsondecode(obj.m_MEData.appConfig.dataFiles.getByKey(configFileKey).configData);


            aTransaction=obj.m_MF0Model.beginTransaction();

            try
                obj.getPromotionData(args);
            catch exp
            end
            aTransaction.commit('parameterpromotiondataloaded');
        end

        function nextId=getNextWidgetId(~)
            nextId=matlab.lang.internal.uuid;
        end



        function getPromotionData(this,args)
            this.m_PromotableParameters={};

            if this.m_Context.isMaskOnMask==1
                this.m_Lookunder='off';
            else
                this.m_Lookunder='on';
            end

            this.m_PromotableRowsArray=simulink.maskeditor.PromotionSelectorRow.empty(0,0);

            blockName=get_param(this.m_Context.blockHandle,'Name');


            addedRowId=this.AddPromotionSelectorBlockRow('null',blockName,false,this.m_filesep);
            rowIdForParameterListNodes=addedRowId;

            insideBlks=this.getBlocksInsideSubsytemForPromotion(this.m_Context.blockHandle,this.m_Lookunder,true);

            relativeParameterPath='';

            if~this.m_Context.isMaskOnModel&&~isempty(insideBlks)
                BPblockName='Block Parameters: '+string(blockName);
                addedBPRowId=this.AddPromotionSelectorBlockRow(addedRowId,BPblockName,false,'');
                rowIdForParameterListNodes=addedBPRowId;

                this.m_MEData.isAllPromotionDataLoaded=false;
            end

            this.AddToPromotableParameterList(this.m_Context.blockHandle,blockName,rowIdForParameterListNodes,relativeParameterPath,true);
            this.GetPromotableParameters(this.m_Context.blockHandle,this.m_Lookunder,addedRowId,relativeParameterPath);

            this.m_MEData.blockPromotableData=this.m_PromotableRowsArray;

            this.loadParametersForPromotionEditMode(args.parametersToLoadForPromotionEditMode);

            this.populateHasBeenPromotedField();
        end


        function populateHasBeenPromotedField(this)

            widgets=this.m_MEData.widgets;

            for i=1:widgets.Size()
                widgetObj=widgets.at(i);
                if widgetObj.widgetMetaData.isPromotedParameter
                    ppListValue=maskeditor.internal.Utils.getPropertyValue(widgetObj,'PromotedParametersList');
                    if isempty(ppListValue)
                        continue;
                    end
                    ppListValue=jsondecode(ppListValue);
                    for k=1:length(ppListValue)
                        ppId=ppListValue{k};
                        ppObj=this.m_MEData.getPromotableRowByKey(ppId);
                        if~isempty(ppObj)
                            ppObj.hasBeenPromoted=true;
                        end
                    end
                end
            end
        end


        function blks=getBlocksInsideSubsytemForPromotion(this,aBlockHandle,lookunder,isBaseBlockInProgress)
            this.m_Lookunder=lookunder;

            if(strcmp(get_param(aBlockHandle,'BlockType'),'SubSystem')&&strcmp(get_param(aBlockHandle,'MaskHideContents'),'on'))
                this.m_Lookunder='none';
            end

            if this.m_Context.isMaskOnModel
                if isBaseBlockInProgress
                    aBlockHandle=bdroot(aBlockHandle);
                end
                blks=find_system(aBlockHandle,'LookUnderMasks',this.m_Lookunder,'SearchDepth',1,...
                'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on');
            else
                blks=find_system(aBlockHandle,'LookUnderMasks',this.m_Lookunder,'SearchDepth',1,...
                'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on');
            end

            blks(1)=[];


            blkTypes=get_param(blks,'BlockType');


            toBeRemoved=Simulink.scopes.getBlockTypesToExcludeFromMaskEdit;


            toBeRemoved=[toBeRemoved,{'ModelMask'}];


            indxToRemove=cellfun(@(bt)strcmp(blkTypes(:),bt),toBeRemoved,'UniformOutput',false);



            indxToRemove=any([indxToRemove{:}],2);



            blks(indxToRemove)=[];
        end


        function GetPromotableParameters(this,aBlockHandle,lookunder,parent,relativeParameterPath)

            blks=this.getBlocksInsideSubsytemForPromotion(aBlockHandle,lookunder,false);

            if~isempty(blks)
                blkHdls=get_param(blks,'Handle');
                if~iscell(blkHdls)
                    blkHdls={blkHdls};
                end

                blkNames=get_param(blks,'Name');
                if~iscell(blkNames)
                    blkNames={blkNames};
                end

                bIsStateFlowBlock=Stateflow.SLUtils.isStateflowBlock(aBlockHandle);

                for i=1:length(blkNames)

                    if((~bIsStateFlowBlock)||(bIsStateFlowBlock&&strcmp(get_param(blkHdls{i},'BlockType'),'SubSystem')))

                        insideBlks=this.getBlocksInsideSubsytemForPromotion(blks(i),'off',false);
                        isSubsystem=~isempty(insideBlks);

                        addedRowId=this.AddPromotionSelectorBlockRow(parent,blkNames{i},isSubsystem,relativeParameterPath);
                        rowIdForParameterListNodes=addedRowId;

                        if~isempty(insideBlks)
                            blockName='Block Parameters: '+string(blkNames{i});
                            [~]=this.AddPromotionSelectorBlockRow(addedRowId,blockName,false,'');

                            continue;
                        end

                        this.AddToPromotableParameterList(blkHdls{i},blkNames{i},rowIdForParameterListNodes,relativeParameterPath,false);
                    end
                end
            end
        end


        function id=AddPromotionSelectorBlockRow(this,parent,aBlockName,isSubsystem,relativeBlockPath)
            if relativeBlockPath==this.m_filesep
                id=relativeBlockPath;
            elseif isempty(relativeBlockPath)
                if string(aBlockName).contains('Block Parameters')
                    id=this.getNextWidgetId();
                else
                    id=aBlockName;
                end
                relativeBlockPath=aBlockName;
            else
                relativeBlockPath=[relativeBlockPath,this.m_filesep,aBlockName];
                id=relativeBlockPath;
            end
            ppRow=simulink.maskeditor.PromotionSelectorRow(this.m_MF0Model,...
            struct('id',id,'parent',parent,'blockName',aBlockName,...
            'relativeBlockPathWithParamName',relativeBlockPath,...
            'isParameter',false,'hasBeenPromoted',false,...
            'isSubsystem',isSubsystem));

            this.m_PromotableRowsArray(end+1)=ppRow;
        end


        function AddToPromotableParameterList(this,aSystemHandle,aBlockName,parent,relativeParameterPath,isBaseBlockInProgress)
            if this.m_Context.blockHandle==aSystemHandle
                if this.m_Context.isMaskOnMask
                    PromoteLevel=this.m_PROMOTE_TO_MASK_ON_MASK;
                else
                    PromoteLevel=this.m_PROMOTE_TO_SELF;
                end
            else
                PromoteLevel=this.m_PROMOTE_TO_SUBSYSTEM;
            end

            parametersData=Simulink.Mask.getPromotableParameters(aSystemHandle,PromoteLevel);

            if~isBaseBlockInProgress
                relativeParameterPath=this.appendToRelativePath(relativeParameterPath,aBlockName);
            end

            for i=1:length(parametersData)
                ppRow=this.populateParameterDataAndProperties(aBlockName,parametersData{i},parent,relativeParameterPath);
                this.m_PromotableRowsArray(end+1)=ppRow;
            end
        end


        function ppRow=populateParameterDataAndProperties(this,aBlockName,parameterData,parent,relativeParameterPath)
            parameterType=parameterData.m_InternalType;

            if strcmp(parameterType,'unidt')
                parameterType='datatypestr';
            end

            propertiesForWidget=this.m_WidgetsPropertyData.widget_properties.(parameterType);
            common_properties=this.m_WidgetsPropertyData.common_properties;

            widgetId=this.getNextWidgetId();

            paramName=char(parameterData.m_Name);
            relativeParameterPath=this.appendToRelativePath(relativeParameterPath,paramName);










            ppRow=simulink.maskeditor.PromotionSelectorRow(this.m_MF0Model,...
            struct('id',relativeParameterPath,'parent',parent,'blockName',aBlockName,...
            'relativeBlockPathWithParamName',relativeParameterPath,...
            'isParameter',true,'hasBeenPromoted',false));

            aPropertiesArray=simulink.maskeditor.Property.empty(0,length(propertiesForWidget));

            for i=1:length(propertiesForWidget)
                property=propertiesForWidget{i};

                if isstruct(propertiesForWidget{i})
                    propertyData=propertiesForWidget{i};
                else
                    propertyData=common_properties.(property);
                end

                propertyId=propertyData.propertyId;

                propertyValue=this.getPropertyValue(parameterType,propertyId,propertyData,parameterData);

                propertyObj=simulink.maskeditor.Property(this.m_MF0Model,...
                struct('widgetId',widgetId,'id',propertyId,...
                'value',propertyValue,'type',propertyData.type));

                aPropertiesArray(i)=propertyObj;
            end
            ppRow.properties=aPropertiesArray;
        end



        function aPropertyValue=getPropertyValue(this,aParameterType,aPropertyId,aPropertyData,aParameterData)
            if strcmp(aPropertyId,'Type')
                aPropertyValue=char(aParameterType);
                return;
            end

            if strcmp(aPropertyId,'TextType')
                mPropertyId='m_TextAreaType';
            else
                mPropertyId=['m_',aPropertyId];
            end

            if strcmp(aPropertyId,'Minimum')
                aPropertyValue=aParameterData.m_Min;
            elseif strcmp(aPropertyId,'Maximum')
                aPropertyValue=aParameterData.m_Max;
            elseif strcmp(aPropertyId,'Prompt')
                aPropertyValue=this.getPromptStucture(aParameterData);
            elseif strcmp(aPropertyId,'Tooltip')
                aPropertyValue=this.getTooltipStructure(aParameterData);
            elseif strcmp(aParameterType,'textarea')&&strcmp(aPropertyId,'Value')
                aPropertyValue=this.getTextAreaValueStructure(aParameterData);
            elseif strcmp(aParameterType,'listbox')&&strcmp(aPropertyId,'Value')
                aPropertyValue=jsonencode(eval(aParameterData.m_Value));
            elseif strcmp(aPropertyId,'TypeOptions')
                aPropertyValue=aParameterData.m_Options;
                if isstruct(aPropertyValue)
                    aPropertyValue=jsonencode(aPropertyValue);
                else
                    aPropertyValue=aParameterData.m_Options;
                end
            elseif strcmp(aPropertyId,'Orientation')
                aPropertyValue=aParameterData.m_Orientation;
                if aPropertyValue==1
                    aPropertyValue='vertical';
                else
                    aPropertyValue='horizontal';
                end
            elseif isfield(aParameterData,mPropertyId)
                aPropertyValue=aParameterData.(mPropertyId);
            else
                aPropertyValue=aPropertyData.defaultValue;
            end

            if isstruct(aPropertyValue)
                aPropertyValue=jsonencode(aPropertyValue);
            elseif~strcmp(aParameterType,'datatypestr')
                aPropertyValue=maskeditor.internal.Utils.changeValueforJS(aParameterType,aPropertyId,aPropertyValue);
            end

            if~ischar(aPropertyValue)
                aPropertyValue=string(aPropertyValue);
            end
        end

        function propertyValue=getPromptStucture(~,parameterData)
            promptId='';
            prompt='';
            if isfield(parameterData,'m_PromptId')
                promptId=parameterData.m_PromptId;
            end
            if isfield(parameterData,'m_Prompt')
                prompt=parameterData.m_Prompt;

            end
            propertyValue=struct('textId',promptId,'text',prompt);

        end

        function propertyValue=getTooltipStructure(~,parameterData)
            tooltipId='';
            tooltip='';

            if isfield(parameterData,'m_ToolTip')
                tooltipId=parameterData.m_ToolTip;
                tooltip=maskeditor.internal.Utils.getTranslatedText(tooltipId);
            end

            propertyValue=struct('textId',tooltipId,'text',tooltip);
        end

        function textAreaValueStr=getTextAreaValueStructure(~,parameterData)
            textAreaValueObject={};
            textAreaValueObject.value=parameterData.m_Value;
            textAreaValueObject.textType=parameterData.m_TextAreaType;

            textAreaValueStr=jsonencode(textAreaValueObject);
        end

        function relativeParameterPath=appendToRelativePath(this,relativeParameterPath,newEntryInPath)
            if isempty(relativeParameterPath)
                relativeParameterPath=newEntryInPath;
            else
                relativeParameterPath=[relativeParameterPath,this.m_filesep,newEntryInPath];
            end
        end


        function addPromotionDataForSubsystemHelper(this,args)
            aSubsystemRowId=args.subsystemRowId;
            aSubsystemBlockParamRowId=args.subsystemBlockParamRowId;

            ppObj=this.m_MEData.getPromotableRowByKey(aSubsystemRowId);
            aBlockHandle=get_param([this.m_MEData.context.blockFullPath,'/',ppObj.relativeBlockPathWithParamName],'Handle');
            relativeParameterPath=ppObj.relativeBlockPathWithParamName;


            this.AddToPromotableParameterList(aBlockHandle,get_param(aBlockHandle,'Name'),aSubsystemBlockParamRowId,relativeParameterPath,true);


            this.GetPromotableParameters(aBlockHandle,this.m_Lookunder,aSubsystemRowId,relativeParameterPath);


            ppObj.isDataLoadedForSubsystem=true;
        end



        function addPromotionDataForASubsystem(this,args)
            try
                if isfield(args,'subsystemRowId')

                    aTransaction=this.m_MF0Model.beginTransaction();
                    this.addPromotionDataForSubsystemHelper(args);
                    this.m_MEData.blockPromotableData=this.m_PromotableRowsArray;

                    this.populateHasBeenPromotedField();
                    aTransaction.commit('parameterpromotiondataloadedforasubsystem');

                elseif isfield(args,'parametersToLoadForPromotionEditMode')

                    this.loadParametersForPromotionEditMode(args.parametersToLoadForPromotionEditMode);
                    this.m_MEData.blockPromotableData=this.m_PromotableRowsArray;

                    this.populateHasBeenPromotedField();
                    aMsgData=struct('Action','parametersLoadedForPromotionEditMode');
                    this.m_MEInstance.m_MessageService.publish('dataModelOperation',aMsgData);
                end
            catch exp
                rethrow(exp);
            end
        end

        function loadParametersForPromotionEditMode(this,parametersToLoadForEditMode)
            aBlockName=this.m_MEData.context.blockName;


            for i=1:length(parametersToLoadForEditMode)
                paramRelativePath=parametersToLoadForEditMode{i};
                splitRelativePath=string(paramRelativePath).split(this.m_filesep);
                aFullPathToLoad=aBlockName;
                idToLoad='';

                for j=1:length(splitRelativePath)-1
                    if(idToLoad=="")
                        idToLoad=splitRelativePath{j};
                    else
                        idToLoad=[idToLoad,this.m_filesep,splitRelativePath{j}];
                    end
                    aFullPathToLoad=[aFullPathToLoad,this.m_filesep,splitRelativePath{j}];

                    ppObj=this.m_MEData.getPromotableRowByKey(idToLoad);




                    if~ppObj.isSubsystem
                        break;
                    end

                    if(~ppObj.isDataLoadedForSubsystem)
                        subsystemBlockParamRowId=this.getSubsystemBlockParamRowId(idToLoad);

                        args=struct('subsystemRowId',idToLoad,'subsystemBlockParamRowId',subsystemBlockParamRowId);
                        this.addPromotionDataForSubsystemHelper(args);
                        this.m_MEData.blockPromotableData=this.m_PromotableRowsArray;
                    end
                end
            end
        end

        function loadAllParameterPromotionData(this)
            this.loadAllParameterPromotionDataHelper("");
            this.m_MEData.blockPromotableData=this.m_PromotableRowsArray;


            this.populateHasBeenPromotedField();
            this.m_MEData.isAllPromotionDataLoaded=true;


            aMsgData=struct('Action','allParameterPromotionDataLoaded');
            this.m_MEInstance.m_MessageService.publish('dataModelOperation',aMsgData);
        end

        function loadAllParameterPromotionDataHelper(this,parentSubsystemId)
            aParameterPromotionData=this.m_MEData.blockPromotableData;


            for i=1:length(aParameterPromotionData)
                ppObj=aParameterPromotionData(i);
                if parentSubsystemId~=""&&string(ppObj.parent)~=parentSubsystemId
                    continue;
                end
                if~ppObj.isSubsystem
                    continue;
                end
                if ppObj.isDataLoadedForSubsystem
                    continue;
                end
                subsystemRowId=ppObj.id;
                subsystemBlockParamRowId=this.getSubsystemBlockParamRowId(subsystemRowId);


                args=struct('subsystemRowId',subsystemRowId,'subsystemBlockParamRowId',subsystemBlockParamRowId);
                this.addPromotionDataForSubsystemHelper(args);
                this.loadAllParameterPromotionDataHelper(subsystemRowId);
            end
        end

        function subsystemBlockParamRowId=getSubsystemBlockParamRowId(this,subsystemRowId)
            subsystemBlockParamRowId='';
            for z=1:length(this.m_PromotableRowsArray)
                rowData=this.m_PromotableRowsArray(z);
                if strcmp(rowData.parent,subsystemRowId)&&string(rowData.blockName).contains('Block Parameters')
                    subsystemBlockParamRowId=rowData.id;
                    break;
                end
            end
        end
    end
end
