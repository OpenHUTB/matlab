classdef loadParameterPromotion<handle



    properties(SetAccess=private,GetAccess=public)
        m_MEInstance;

        m_Context;
        m_MF0Model;
        m_MEData;

        m_PromotableParameters;
        m_WidgetsPropertyData;
        m_Utils;
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

        function obj=loadParameterPromotion(aMEInstance,~)
            obj.m_MEInstance=aMEInstance;

            obj.m_Context=aMEInstance.m_Context;
            obj.m_MF0Model=aMEInstance.m_MF0Model;
            obj.m_MEData=aMEInstance.m_MEData;

            configFileKey=obj.ConfigConstants.WIDGET_PROPERTIES;
            obj.m_WidgetsPropertyData=jsondecode(obj.m_MEData.appConfig.dataFiles.getByKey(configFileKey).configData);

            obj.m_Utils=maskeditor.internal.Utils();

            aTransaction=obj.m_MF0Model.beginTransaction();

            obj.getPromotionData();

            aTransaction.commit('parameterpromotiondataloaded');
        end

        function nextId=getNextWidgetId(~)
            nextId=matlab.lang.internal.uuid;
        end



        function getPromotionData(this)
            this.m_PromotableParameters={};

            this.m_PromotableRowsArray=simulink.maskeditor.PromotionSelectorRow.empty(0,0);

            blockName=get_param(this.m_Context.blockHandle,'Name');



            addedRowId=this.AddPromotionSelectorBlockRow('null',blockName);
            rowIdForParameterListNodes=addedRowId;

            insideBlks=this.getComponentsWithParametersForPromotion(this.m_Context.blockHandle);

            relativeParameterPath='';







            this.AddToPromotableParameterList(this.m_Context.blockHandle,blockName,rowIdForParameterListNodes,relativeParameterPath,true);
            this.GetPromotableParameters(this.m_Context.blockHandle,addedRowId,relativeParameterPath);

            this.m_MEData.blockPromotableData=this.m_PromotableRowsArray;
            this.m_PromotableRowsArray=[];

            this.populateHasBeenPromotedField();
        end


        function populateHasBeenPromotedField(this)

            widgets=this.m_MEData.widgets;

            for i=1:widgets.Size()
                widgetObj=widgets.at(i);
                if widgetObj.widgetMetaData.isPromotedParameter
                    ppListValue=this.m_Utils.getPropertyValue(widgetObj,'PromotedParametersList');
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


        function comps=getComponentsWithParametersForPromotion(~,blockHandle)

            comps={};
            zcModel=get_param(bdroot(blockHandle),'SystemComposerModel');
            parentComp=systemcomposer.arch.BaseComponent.empty(1,0);

            if isa(get_param(blockHandle,'Object'),'Simulink.BlockDiagram')
                parentArch=zcModel.Architecture;
            else
                parentComp=systemcomposer.utils.getArchitecturePeer(blockHandle);
                parentComp=systemcomposer.internal.getWrapperForImpl(parentComp);
                if parentComp.isReference
                    return;
                end
                parentArch=parentComp.Architecture;
            end

            comps=parentArch.Components;
        end


        function GetPromotableParameters(this,blockHandle,parent,relativeParameterPath)

            comps=this.getComponentsWithParametersForPromotion(blockHandle);

            for i=1:numel(comps)
                blkHdls{i}=comps(i).SimulinkHandle;
                blkNames{i}=comps(i).Name;

                addedRowId=this.AddPromotionSelectorBlockRow(parent,blkNames{i});
                rowIdForParameterListNodes=addedRowId;

                subComps=this.getComponentsWithParametersForPromotion(blkHdls{i});

                if~isempty(subComps)
                    blockName='Parameters: '+string(blkNames{i});
                    addedBPRowId=this.AddPromotionSelectorBlockRow(addedRowId,blockName);
                    rowIdForParameterListNodes=addedBPRowId;
                end

                this.AddToPromotableParameterList(blkHdls{i},blkNames{i},rowIdForParameterListNodes,relativeParameterPath,false);

                cachedRelativeParameterPath=relativeParameterPath;
                if~isempty(subComps)
                    relativeParameterPath=this.appendToRelativePath(relativeParameterPath,blkNames{i});
                end

                this.GetPromotableParameters(blkHdls{i},addedRowId,relativeParameterPath);

                relativeParameterPath=cachedRelativeParameterPath;
            end
        end



        function id=AddPromotionSelectorBlockRow(this,parent,aBlockName)
            id=this.getNextWidgetId();

            ppRow=simulink.maskeditor.PromotionSelectorRow(this.m_MF0Model,...
            struct('id',id,'parent',parent,'blockName',aBlockName,...
            'isParameter',false,'hasBeenPromoted',false));

            this.m_PromotableRowsArray(end+1)=ppRow;
        end


        function AddToPromotableParameterList(this,blockHandle,aBlockName,parent,relativeParameterPath,isBaseBlockInProgress)

            if~isa(get_param(blockHandle,'Object'),'Simulink.BlockDiagram')
                parentComp=systemcomposer.internal.getWrapperForImpl(systemcomposer.utils.getArchitecturePeer(blockHandle));
                parametersData=parentComp.getParameterNames;

                if~isBaseBlockInProgress
                    relativeParameterPath=this.appendToRelativePath(relativeParameterPath,aBlockName);

                    for i=1:length(parametersData)
                        ppRow=this.populateParameterDataAndProperties(parentComp,parametersData{i},parent,relativeParameterPath);
                        if isempty(this.m_PromotableRowsArray.findobj('id',ppRow.id))
                            this.m_PromotableRowsArray(end+1)=ppRow;
                        else
                            newId=[ppRow.id,'_',char(matlab.lang.internal.uuid)];
                            ppRow.id=newId;
                            this.m_PromotableRowsArray(end+1)=ppRow;
                        end
                    end
                end
            end
        end


        function ppRow=populateParameterDataAndProperties(this,compInst,parameterName,parent,relativeParameterPath)
            parameterType='edit';

            propertiesForWidget=this.m_WidgetsPropertyData.widget_properties.(parameterType);
            common_properties=this.m_WidgetsPropertyData.common_properties;

            widgetId=this.getNextWidgetId();

            relativeParameterPath=this.appendToRelativePath(relativeParameterPath,parameterName);










            ppRow=simulink.maskeditor.PromotionSelectorRow(this.m_MF0Model,...
            struct('id',relativeParameterPath,'parent',parent,'blockName',compInst.Name,...
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

                propertyValue=this.getPropertyValue(parameterType,propertyId,propertyData,compInst,parameterName);

                propertyObj=simulink.maskeditor.Property(this.m_MF0Model,...
                struct('widgetId',widgetId,'id',propertyId,...
                'value',propertyValue,'type',propertyData.type));

                aPropertiesArray(i)=propertyObj;
            end
            ppRow.properties=aPropertiesArray;
        end





        function relativeBlockPathWithParamName=getRelativeBlockPathWithParamName(~,aBlockHandle,parameterData)
            fullblockpath=getfullname(aBlockHandle);
            paramName=string(parameterData.m_Name);
            fullBlockPathWithParamName=fullblockpath+"/"+paramName;
            fullBlockPathWithParamNameArray=split(fullBlockPathWithParamName,'/');
            relativeBlockPathWithParamName=join(fullBlockPathWithParamNameArray(3:end),'/');
        end



        function propertyValue=getPropertyValue(this,parameterType,propertyId,propertyData,compInst,parameterName)
            if strcmp(propertyId,'Type')
                propertyValue=char(parameterType);
                return;
            end

            mpropertyId="m_"+propertyId;

            if strcmp(propertyId,'Name')
                propertyValue=string(parameterName);
            elseif strcmp(propertyId,'Value')
                propertyValue=compInst.getParameterValue(parameterName);
            elseif strcmp(propertyId,'Prompt')
                propertyValue=this.getPromptStucture(parameterName);
            elseif strcmp(propertyId,'Tooltip')
                propertyValue=this.getTooltipStructure(parameterName);
            else
                propertyValue=propertyData.defaultValue;
            end

            propertyValue=string(this.m_Utils.changeValueforJS(parameterType,propertyId,propertyValue));



        end

        function propertyValue=getPromptStucture(~,parameterName)
            promptId='';
            prompt=parameterName;
            propertyValue=struct('textId',promptId,'text',prompt);

        end

        function propertyValue=getTooltipStructure(this,parameterName)

            tooltipId='';
            tooltip=parameterName;

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

    end
end
