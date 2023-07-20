classdef loadMask<handle

    properties
        m_MEInstance;

m_Context
        m_MEData;
        m_MF0Model;

        m_Utils;
        m_WidgetsPropertyData;

        m_MaskObj;
    end

    properties(Constant)
        ConfigConstants=maskeditor.internal.loadsave.ConfigConstants();
    end

    properties(Access='private')
        MFListener;
CurrentElement
    end

    methods
        function obj=loadMask(aMEInstance)
            obj.m_MEInstance=aMEInstance;

            obj.m_Context=obj.m_MEInstance.m_Context;
            obj.m_MF0Model=obj.m_MEInstance.m_MF0Model;
            obj.m_MEData=obj.m_MEInstance.m_MEData;

            configFileKey=obj.ConfigConstants.WIDGET_PROPERTIES;

            obj.m_WidgetsPropertyData=jsondecode(obj.m_MEData.appConfig.dataFiles.getByKey(configFileKey).configData);

            obj.m_Utils=maskeditor.internal.Utils();

            aTransaction=obj.m_MF0Model.beginTransaction();

            obj.populateMask;

            aTransaction.commit();

            modelName=get_param(bdroot(obj.m_Context.blockHandle),'Name');
            obj.MFListener=systemcomposer.internal.parameters.editor.EditorModelListener(modelName,obj.m_MF0Model);
        end

        function populateMask(this)
            blockHandle=this.m_Context.blockHandle;
            bdH=bdroot(blockHandle);
            this.m_MEData.selfModifiable=false;
            this.m_MEData.initialization='';
            zcModel=get_param(bdH,'SystemComposerModel');
            zcElem=zcModel.lookup('SimulinkHandle',blockHandle);

            this.populateBlockContextDetails();

            this.createDefaultsWidgets();

            if~isempty(zcElem)&&isa(zcElem,'systemcomposer.arch.BaseComponent')
                if zcElem.isReference
                    return;
                else
                    zcElem=zcElem.Architecture;
                end
            end
            this.CurrentElement=zcElem;
            if~isempty(zcElem)&&isa(zcElem,'systemcomposer.arch.Architecture')
                paramNames=zcElem.getParameterNames;
                parentId=this.getWidgetIdForWidgetName(this.m_MEData.widgets,'ParameterGroupVar');

                for i=1:length(paramNames)
                    pName=paramNames(i);

                    if~pName.matches("")
                        widgetObj=this.createWidget('edit',parentId,pName);
                        this.m_MEData.widgets.add(widgetObj);
                    end
                end
            end
        end


        function populateBlockContextDetails(this)
            aBlockHdl=this.m_Context.blockHandle;
            aModelHdl=bdroot(aBlockHdl);

            bIsMaskOnModelRef=false;
            bIsMaskOnSsref=false;
            aFullPath=getfullname(aBlockHdl);
            bBDIsLibrary=bdIsLibrary(aModelHdl);
            try
                blockType=get_param(aBlockHdl,'blockType');
            catch
                blockType='BlockDiagram';
            end
            this.m_MEData.context=simulink.maskeditor.BlockContext(this.m_MF0Model,...
            struct(...
            'blockHandle',aBlockHdl,...
            'blockName',get_param(aBlockHdl,'Name'),...
            'blockType',blockType,...
            'blockFullPath',aFullPath,...
            'readOnly',this.m_Context.isReadOnly,...
            'dialogTitle',this.m_Context.dialogTitle,...
            'maskOnMask',this.m_Context.isMaskOnMask,...
            'maskOnModel',this.m_Context.isMaskOnModel,...
            'maskOnModelRef',bIsMaskOnModelRef,...
            'maskOnSsref',bIsMaskOnSsref,...
            'bdIsLibrary',bBDIsLibrary,...
            'canChangePortRotate',false)...
            );
        end

        function widget=createWidget(this,widgetType,parentId,paramName)
            widgetId=matlab.lang.internal.uuid;

            widget=simulink.maskeditor.Widget(this.m_MF0Model,...
            struct('id',widgetId,'parent',parentId));



            isPromoted=false;
            isParameter=true;
            if this.CurrentElement.getImpl.isPromotedParameter(paramName)
                isPromoted=true;
            end

            propertiesForWidget=this.m_WidgetsPropertyData.widget_properties.(widgetType);
            common_properties=this.m_WidgetsPropertyData.common_properties;
            aWidgetPropertiesArray=simulink.maskeditor.Property.empty(1,0);
            for i=1:length(propertiesForWidget)
                property=propertiesForWidget{i};

                if isstruct(propertiesForWidget{i})
                    propertyData=propertiesForWidget{i};
                else
                    propertyData=common_properties.(property);
                end

                propertyId=propertyData.propertyId;

                propertyValue=this.getPropertyValue(widgetType,propertyId,paramName);

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

            if isPromoted
                propertyId='PromotedParametersList';
                propertyData=common_properties.(propertyId);
                propertyValue=this.getPropertyValue(widgetType,propertyId,paramName);
                propertyObj=simulink.maskeditor.Property(this.m_MF0Model,...
                struct('widgetId',widgetId,...
                'id',propertyId,...
                'value',propertyValue,...
                'type',propertyData.type));
                aWidgetPropertiesArray(end+1)=propertyObj;
            end

            widget.properties=aWidgetPropertiesArray;

            widget.widgetMetaData=simulink.maskeditor.WidgetMetaData(this.m_MF0Model,...
            struct('isPromotedParameter',isPromoted,...
            'isParameter',isParameter));
        end


        function widget=createWidgetObjectforNewMask(this,type,parent,widgetId,name,prompt)

            widget=simulink.maskeditor.Widget(this.m_MF0Model,...
            struct('id',widgetId,'parent',parent));

            widget.widgetMetaData=simulink.maskeditor.WidgetMetaData(this.m_MF0Model,...
            struct('isPromotedParameter',false,'isParameter',false));

            propertiesForWidget=this.m_WidgetsPropertyData.widget_properties.(type);

            aWidgetPropertiesArray=simulink.maskeditor.Property.empty(1,0);
            for i=1:length(propertiesForWidget)
                property=propertiesForWidget{i};
                common_properties=this.m_WidgetsPropertyData.common_properties;

                if isstruct(propertiesForWidget{i})
                    propertyData=propertiesForWidget{i};
                else
                    propertyData=common_properties.(property);
                end

                if strcmp(propertyData.propertyId,'Name')
                    propertyValue=name;
                elseif strcmp(propertyData.propertyId,'Type')
                    propertyValue=type;
                elseif strcmp(propertyData.propertyId,'Prompt')
                    propertyValue=jsonencode(struct('textId',prompt,'text',prompt));
                elseif strcmp(propertyData.propertyId,'Tooltip')
                    propertyValue=propertyData.defaultValue;
                else
                    propertyValue=string(propertyData.defaultValue);
                end

                propertyObj=simulink.maskeditor.Property(this.m_MF0Model,...
                struct('widgetId',widgetId,...
                'id',propertyData.propertyId,...
                'value',propertyValue,...
                'type',propertyData.type));

                aWidgetPropertiesArray(end+1)=propertyObj;
            end
            widget.properties=aWidgetPropertiesArray;
        end

        function createDefaultsWidgets(this)
            id1=matlab.lang.internal.uuid;
            widget=this.createWidgetObjectforNewMask('group','null',id1,'ParameterGroupVar',DAStudio.message('Simulink:studio:ToolBarParametersMenu'));
            this.m_MEData.widgets.add(widget);
        end


        function aWidgets=createWidgets(this,aDialogControls,aParent,aWidgets)


            for i=1:length(aDialogControls)
                aDialogControl=aDialogControls(i);
                [aWidgets,aAddedWidgetId]=this.createAndAddWidget(aDialogControl,aParent,aWidgets);
                if isprop(aDialogControl,'DialogControls')
                    aWidgets=this.createWidgets(aDialogControl.DialogControls,aAddedWidgetId,aWidgets);
                end
            end
        end

        function[widgets,addedWidgetId]=createAndAddWidget(this,dialogControl,parentId,widgets)
            if this.m_Utils.isContainer(dialogControl)||this.m_Utils.isDialogControl(dialogControl)
                isParameter=false;
            else
                isParameter=true;
            end
            [widget,addedWidgetId]=this.createWidget(dialogControl,parentId,isParameter);
            widgets(end+1)=widget;
        end


        function propertyValue=getPropertyValue(this,widgetType,propertyId,paramName)
            if strcmp(propertyId,'Type')
                propertyValue=string(widgetType);
                return;
            end

            propertyValue='';
            paramDef=this.CurrentElement.getParameterDefinition(paramName);
            switch propertyId
            case 'Name'
                propertyValue=paramName;
            case 'DataType'
                if~isempty(paramDef)
                    propertyValue=paramDef.Type;
                end
            case 'Value'
                propertyValue=this.CurrentElement.getParameterValue(paramName);
            case 'Unit'
                if~isempty(paramDef)
                    propertyValue=paramDef.Units;
                end
            case 'Min'
                if~isempty(paramDef)
                    propertyValue=paramDef.Minimum;
                end
            case 'Max'
                if~isempty(paramDef)
                    propertyValue=paramDef.Maximum;
                end
            case 'Dimensions'
                if~isempty(paramDef)
                    propertyValue=paramDef.Dimensions;
                end
            case 'PromotedParametersList'
                promotedComp=this.CurrentElement.getImpl.getComponentPromotedFrom(paramName);
                if~isempty(promotedComp)
                    fullPathOfSrc=promotedComp.getQualifiedName;
                    relativePathOfSrc=strrep(fullPathOfSrc,[this.CurrentElement.getImpl.getQualifiedName,'/'],'');
                    baseParamName=string(strrep(paramName,relativePathOfSrc,''));
                    if baseParamName.startsWith(".")
                        baseParamName=baseParamName.extractAfter(".");
                    end
                    if baseParamName.startsWith("/")
                        baseParamName=baseParamName.extractAfter("/");
                    end
                    propertyValue=[relativePathOfSrc,'/',baseParamName.char];

                    propertyValue=jsonencode({propertyValue});
                end
            end

            if strcmp(propertyId,'Prompt')
                promptId='';
                propertyValue=struct('textId',promptId,'text',this.m_Utils.getTranslatedText(paramName));
            elseif strcmp(propertyId,'Tooltip')
                tooltipId='';
                propertyValue=struct('textId',tooltipId,'text',this.m_Utils.getTranslatedText(tooltipId));
            end

            propertyValue=string(this.m_Utils.changeValueforJS(widgetType,propertyId,propertyValue));
        end

        function id=getWidgetIdForWidgetName(~,widgets,widgetName)
            id=[];
            for i=1:widgets.Size()
                widget=findobj(widgets(i).properties,'id','Name');
                if~isempty(widget)&&strcmpi(widget.value,widgetName)
                    id=widgets(i).id;
                    return;
                end
            end
        end
    end
end
