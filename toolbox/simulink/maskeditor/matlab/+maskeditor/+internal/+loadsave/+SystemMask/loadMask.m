classdef loadMask<handle





    properties
        m_MEInstance;

m_Context
        m_MEData;
        m_MF0Model;

        m_WidgetsPropertyData;
        m_MaskDataLoader;

        m_MaskObj;
    end

    properties(Constant)
        ConfigConstants=maskeditor.internal.loadsave.ConfigConstants();
    end

    methods

        function obj=loadMask(aMEInstance)
            obj.m_MEInstance=aMEInstance;
            obj.m_MaskDataLoader=maskeditor.internal.loadsave.SubsystemOrCoreBlock.loadMask(aMEInstance);

            obj.m_Context=obj.m_MaskDataLoader.m_Context;
            obj.m_MF0Model=obj.m_MaskDataLoader.m_MF0Model;
            obj.m_MEData=obj.m_MaskDataLoader.m_MEData;

            obj.m_WidgetsPropertyData=obj.m_MaskDataLoader.m_WidgetsPropertyData;

            [obj.m_MaskObj]=Simulink.Mask.get(obj.m_Context.blockHandle);

            aTransaction=obj.m_MF0Model.beginTransaction();

            if isempty(obj.m_MaskObj)||~obj.m_MaskObj.isMaskWithDialog
                if(obj.m_Context.isMaskOnModel)
                    obj.createDefaultModelMask();
                end
            else
                obj.m_MaskDataLoader.getMaskData();
            end

            aTransaction.commit();
        end

        function createDefaultModelMask(this)
            blockHandle=this.m_Context.blockHandle;
            aModelMaskObj=Simulink.Mask.get(blockHandle);
            aModelHdl=bdroot(blockHandle);

            this.m_MaskDataLoader.populateBlockContextDetails();
            this.m_MaskDataLoader.populateIconProperties();

            aDefaultModelMaskInfo=Simulink.Mask.getDefaultModelMaskInfo(aModelHdl);

            docStruct=struct;
            if isempty(aModelMaskObj)
                docStruct=struct('type',aDefaultModelMaskInfo.Type,'description',aDefaultModelMaskInfo.Description);
            end
            this.m_MEData.documentation=simulink.maskeditor.Documentation(this.m_MF0Model,docStruct);

            this.m_MaskDataLoader.createThreeDefaultsWidgets();

            aModelArgs=[aDefaultModelMaskInfo.ModelParameterArguments;aDefaultModelMaskInfo.BlockParameterArguments];
            parentId=this.getWidgetIdForWidgetName(this.m_MEData.widgets,'ParameterGroupVar');

            for i=1:length(aModelArgs)

                if(isempty(aModelMaskObj)||isempty(aModelMaskObj.getParameter(aModelArgs(i).Name)))



                    widgetObj=this.createWidget('edit',parentId,true);
                    this.m_MEData.widgets.add(widgetObj);

                    widgetObj.getPropertyByKey('Name').value=aModelArgs(i).Name;

                    promptId=aModelArgs(i).Prompt;
                    promptStruct=struct('textId',promptId,'text',maskeditor.internal.Utils.getTranslatedText(promptId));
                    widgetObj.getPropertyByKey('Prompt').value=jsonencode(promptStruct);

                    widgetObj.getPropertyByKey('Value').value=aModelArgs(i).Value;
                end
            end
        end

        function widget=createWidget(this,widgetType,parentId,isParameter)
            widgetId=matlab.lang.internal.uuid;

            widget=simulink.maskeditor.Widget(this.m_MF0Model,...
            struct('id',widgetId,'parent',parentId));

            propertiesForWidget=this.m_WidgetsPropertyData.widget_properties.(widgetType);
            common_properties=this.m_WidgetsPropertyData.common_properties;

            for i=1:length(propertiesForWidget)
                property=propertiesForWidget{i};

                if isstruct(propertiesForWidget{i})
                    propertyData=propertiesForWidget{i};
                else
                    propertyData=common_properties.(property);
                end

                propertyId=propertyData.propertyId;

                propertyValue=this.getPropertyValue(widgetType,propertyId,propertyData);

                propertyObj=simulink.maskeditor.Property(this.m_MF0Model,...
                struct('widgetId',widgetId,...
                'id',propertyId,...
                'value',propertyValue,...
                'type',propertyData.type));

                if i==1
                    aWidgetPropertiesArray=propertyObj;
                else
                    aWidgetPropertiesArray(end+1)=propertyObj;%#ok<AGROW>
                end
            end
            widget.properties=aWidgetPropertiesArray;

            widget.widgetMetaData=simulink.maskeditor.WidgetMetaData(this.m_MF0Model,...
            struct('isPromotedParameter',false,...
            'isParameter',isParameter));
        end

        function propertyValue=getPropertyValue(~,widgetType,propertyId,propertyData)
            if strcmp(propertyId,'Type')
                propertyValue=string(widgetType);
                return;
            end
            propertyValue=propertyData.defaultValue;

            if strcmp(propertyId,'Prompt')
                promptId='';
                propertyValue=struct('textId',promptId,'text',maskeditor.internal.Utils.getTranslatedText(promptId));
            elseif strcmp(propertyId,'Tooltip')
                tooltipId='';
                propertyValue=struct('textId',tooltipId,'text',maskeditor.internal.Utils.getTranslatedText(tooltipId));
            end

            propertyValue=string(maskeditor.internal.Utils.changeValueforJS(widgetType,propertyId,propertyValue));
        end

        function id=getWidgetIdForWidgetName(~,widgets,widgetName)
            id=[];
            for i=1:widgets.Size()
                if strcmpi(widgets(i).getPropertyByKey('Name').value,widgetName)
                    id=widgets(i).id;
                    return;
                end
            end
        end

        function refreshModelMaskEditor(this,~,aData)
            aRefreshAction=aData.Action;
            switch aRefreshAction
            case 'Rename'
                aOldWidgetName=aData.OldWidgetName;
                aNewWidgetName=aData.NewWidgetName;
                widgetObj=this.getWidgetFromWidgetCollection(aOldWidgetName);
                if isempty(widgetObj)
                    return;
                end
                aTransaction=this.m_MF0Model.beginTransaction();
                namePropObj=widgetObj.getPropertyByKey('Name');
                namePropObj.value=aNewWidgetName;
                aTransaction.commit('refreshmaskeditor');
            case 'AddRemoveParameter'
                aWidgetName=aData.WidgetName;
                bIsArgument=aData.IsArgument;
                if bIsArgument
                    aTransaction=this.m_MF0Model.beginTransaction();
                    aNewWidgetObj=this.createWidget('edit','null',true);
                    this.m_MEData.widgets.add(aNewWidgetObj);
                    aNewWidgetObj.getPropertyByKey('Name').value=aWidgetName;
                    promptStruct=struct('textId',aWidgetName,'text',maskeditor.internal.Utils.getTranslatedText(aWidgetName));
                    aNewWidgetObj.getPropertyByKey('Prompt').value=jsonencode(promptStruct);
                    aTransaction.commit('refreshmaskeditor');
                else
                    widgetObj=this.getWidgetFromWidgetCollection(aWidgetName);
                    if isempty(widgetObj)
                        return;
                    end
                    aTransaction=this.m_MF0Model.beginTransaction();
                    widgetObj.destroy();
                    aTransaction.commit('refreshmaskeditor');
                end
            end
        end

        function ret=getWidgetFromWidgetCollection(this,widgetName)
            ret=[];
            widgets=this.m_MEData.widgets;
            for i=1:widgets.Size()
                if strcmpi(widgets(i).getPropertyByKey('Name').value,widgetName)
                    ret=widgets(i);
                    return;
                end
            end
        end
    end
end

