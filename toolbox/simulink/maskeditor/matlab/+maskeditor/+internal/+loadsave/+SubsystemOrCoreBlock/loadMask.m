classdef loadMask<handle





    properties
        m_MEInstance;

m_Context
        m_MEData;
        m_MF0Model;

        m_WidgetsPropertyData;

        m_MaskObj;
    end

    properties(Constant)
        ConfigConstants=maskeditor.internal.loadsave.ConfigConstants();
    end

    methods

        function obj=loadMask(aMEInstance)
            obj.m_MEInstance=aMEInstance;

            obj.m_Context=aMEInstance.m_Context;
            obj.m_MF0Model=aMEInstance.m_MF0Model;
            obj.m_MEData=aMEInstance.m_MEData;

            configFileKey=obj.ConfigConstants.WIDGET_PROPERTIES;

            obj.m_WidgetsPropertyData=jsondecode(obj.m_MEData.appConfig.dataFiles.getByKey(configFileKey).configData);


            if strcmp(obj.m_Context.systemType,'SUBSYSTEM_OR_CORE_BLOCK')||...
                strcmp(obj.m_Context.systemType,'SYSTEM_OBJECT_MASK')
                obj.getMaskData();

                if obj.m_MEData.context.maskOnSsref
                    aMEInstance.m_ConfigLoader.changeConfiguration({'General','appTitle'},'Editori18n.SystemMaskDialogTitle');
                end
            end
        end


        function getMaskData(this)
            [this.m_MaskObj,bCanCreateNew]=Simulink.Mask.get(this.m_Context.blockHandle);
            if bCanCreateNew&&this.m_Context.isMaskOnMask
                this.m_MaskObj=[];
            end


            this.populateMaskData();
        end

        function importMask(this,aMaskObjToImport)
            aCachedMaskObj=this.m_MaskObj;
            this.m_MaskObj=aMaskObjToImport;

            this.populateMaskData();

            this.m_MaskObj=aCachedMaskObj;
        end

        function createMaskOnLink(this)
            this.m_Context=this.m_MEInstance.m_Context;
            this.getMaskData();

            aMaskObj=Simulink.Mask.get(this.m_Context.blockHandle);
            if~isempty(aMaskObj)
                if strcmp(aMaskObj.SelfModifiable,'off')
                    this.m_MEData.selfModifiable=false;
                else
                    this.m_MEData.selfModifiable=true;
                end
                this.m_MEData.documentation.type=aMaskObj.Type;
            end
        end


        function populateMaskData(this)
            aTransaction=this.m_MF0Model.beginTransaction();

            this.populateBlockContextDetails();

            this.populateIconProperties();

            this.populateDocumentationDetails();

            aMaskObj=this.m_MaskObj;
            if isempty(aMaskObj)
                this.m_MEData.selfModifiable=false;
                this.m_MEData.initialization='';

                this.m_MEData.widgets.clear();
                this.createThreeDefaultsWidgets();
            else
                if strcmp(aMaskObj.SelfModifiable,'off')
                    this.m_MEData.selfModifiable=false;
                else
                    this.m_MEData.selfModifiable=true;
                end

                this.m_MEData.initialization=aMaskObj.Initialization;

                this.getWidgetsForExistingMask(aMaskObj.DialogControls,this.m_MEData.widgets);
            end

            aTransaction.commit();
        end

        function aWidgets=getWidgetsForExistingMask(this,aDialogControls,aWidgets)
            aWidgets.clear();
            aWidgets=this.createWidgets(aDialogControls,'null',aWidgets);
            this.populateDTSParamsAssociationsFields(aWidgets);
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
            if maskeditor.internal.Utils.isContainer(dialogControl)||maskeditor.internal.Utils.isDialogControl(dialogControl)
                isParameter=false;
            else
                isParameter=true;
            end

            [widget,addedWidgetId]=this.createWidget(dialogControl,parentId,isParameter);
            widgets(end+1)=widget;
        end



        function[widget,widgetId]=createWidget(this,dialogControl,parentId,isParameter)
            widgetId=matlab.lang.internal.uuid;

            widgetType=this.getWidgetTypefromClass(dialogControl,isParameter);

            widget=simulink.maskeditor.Widget(this.m_MF0Model,...
            struct('id',widgetId,...
            'parent',parentId));

            propertiesForWidget=this.m_WidgetsPropertyData.widget_properties.(widgetType);
            common_properties=this.m_WidgetsPropertyData.common_properties;

            propertyMap=[];
            if isParameter
                propertyMap=this.m_MaskObj.getParameter(dialogControl.Name);
            end

            isPromotedMaskParameter=this.getIsPromotedParameter(propertyMap,isParameter);

            aPropertyObj=struct('widgetId',widgetId,...
            'id','',...
            'value','',...
            'type','');
            aWidgetPropertiesArray=simulink.maskeditor.Property.empty(0,length(propertiesForWidget));

            itr_propertiesArray=0;
            for i=1:length(propertiesForWidget)
                aProperty=propertiesForWidget{i};

                if~isstruct(aProperty)
                    aProperty=common_properties.(aProperty);
                end

                aPropertyId=aProperty.propertyId;

                if isPromotedMaskParameter&&strcmp(aPropertyId,'TypeOptions')
                    continue;
                end

                aPropertyObj.id=aPropertyId;
                aPropertyObj.type=aProperty.type;
                aPropertyObj.value=this.getPropertyValue(dialogControl,widgetType,aPropertyId,propertyMap,isParameter,widget);

                itr_propertiesArray=itr_propertiesArray+1;
                aWidgetPropertiesArray(itr_propertiesArray)=simulink.maskeditor.Property(this.m_MF0Model,aPropertyObj);
            end

            if isPromotedMaskParameter
                aPPListPropertyObj=this.getPPListPropertyForPromotedMaskParameter(widget,propertyMap,common_properties);
                aWidgetPropertiesArray(end+1)=aPPListPropertyObj;
            end

            if itr_propertiesArray<length(propertiesForWidget)
                aWidgetPropertiesArray=aWidgetPropertiesArray(1:length(aWidgetPropertiesArray));
            end

            widget.properties=aWidgetPropertiesArray;

            widget.widgetMetaData=simulink.maskeditor.WidgetMetaData(this.m_MF0Model,...
            struct('isPromotedParameter',isPromotedMaskParameter,...
            'isParameter',isParameter));
        end



        function propertyValue=getPropertyValue(this,dialogControl,widgetType,propertyId,propertyMap,isParameter,widget)
            if strcmp(propertyId,'Type')
                propertyValue=string(widgetType);
                return;
            end
            if isParameter
                if isprop(dialogControl,propertyId)
                    propertyValue=dialogControl.(propertyId);
                    if strcmp(propertyId,'Tooltip')
                        propertyValue=struct('textId',propertyValue,'text',maskeditor.internal.Utils.getTranslatedText(propertyValue));
                    end
                else
                    if strcmp(widgetType,'datatypestr')&&strcmp(propertyId,'TypeOptions')
                        propertyValue=propertyMap.Type;
                    elseif strcmp(propertyId,'Minimum')
                        propertyValue=string(propertyMap.Range(1));
                    elseif strcmp(propertyId,'Maximum')
                        propertyValue=string(propertyMap.Range(2));
                    elseif strcmp(widgetType,'customtable')&&strcmp(propertyId,'Value')
                        propertyValue=this.getCustomTableValue(propertyMap);
                    elseif strcmp(widgetType,'textarea')&&strcmp(propertyId,'Value')
                        propertyValue=this.getTextAreaValue(propertyMap);
                    elseif strcmp(propertyId,'Prompt')
                        promptId=propertyMap.(propertyId);
                        propertyValue=struct('textId',promptId,'text',maskeditor.internal.Utils.getTranslatedText(promptId));
                    elseif strcmp(propertyId,'Enabled')||strcmp(propertyId,'Visible')
                        propertyValue=this.handleSettingReadOnlyAndHidden(propertyId,widget,propertyMap);
                    elseif strcmp(widgetType,'popup')&&strcmp(propertyId,'TypeOptions')
                        propertyValue=this.getTunablePopupOptionsValue(propertyMap.(propertyId));
                    elseif strcmp(widgetType,'listbox')&&strcmp(propertyId,'Value')
                        propertyValue=this.getListboxValue(propertyMap);
                    elseif strcmp(propertyId,'ConstraintName')
                        propertyValue=this.getConstraintIdForPropertyEditor(propertyMap);
                    else
                        propertyValue=propertyMap.(propertyId);
                    end
                end
            else
                if strcmp(propertyId,'Prompt')
                    promptId=dialogControl.(propertyId);
                    propertyValue=struct('textId',promptId,'text',maskeditor.internal.Utils.getTranslatedText(promptId));
                elseif strcmp(propertyId,'Tooltip')
                    propertyValue=dialogControl.(propertyId);
                    propertyValue=struct('textId',propertyValue,'text',maskeditor.internal.Utils.getTranslatedText(propertyValue));
                else
                    propertyValue=dialogControl.(propertyId);
                end
            end

            propertyValue=string(maskeditor.internal.Utils.changeValueforJS(widgetType,propertyId,propertyValue));

        end

        function createThreeDefaultsWidgets(this)
            id1=matlab.lang.internal.uuid;
            widget=this.createWidgetObjectforNewMask('group','null',id1,'DescGroupVar','%<MaskType>');
            this.m_MEData.widgets.add(widget);

            id2=matlab.lang.internal.uuid;
            widget=this.createWidgetObjectforNewMask('text',id1,id2,'DescTextVar','%<MaskDescription>');
            this.m_MEData.widgets.add(widget);

            id3=matlab.lang.internal.uuid;
            widget=this.createWidgetObjectforNewMask('group','null',id3,'ParameterGroupVar',DAStudio.message('Simulink:studio:ToolBarParametersMenu'));
            this.m_MEData.widgets.add(widget);
        end


        function propertyObj=getPPListPropertyForPromotedMaskParameter(this,widgetObj,propertyMap,common_properties)
            propertyId='PromotedParametersList';
            propertyData=common_properties.(propertyId);
            propertyValue=jsonencode(propertyMap.TypeOptions);
            propertyObj=simulink.maskeditor.Property(this.m_MF0Model,...
            struct('widgetId',widgetObj.id,'id',propertyId,...
            'value',propertyValue,'type',propertyData.type));
        end




        function propertyValue=handleSettingReadOnlyAndHidden(~,propertyId,widget,propertyMap)
            propertyValue=propertyMap.(propertyId);

            if strcmp(propertyId,'Enabled')
                readOnlypropObj=widget.getPropertyByKey('ReadOnly');
                if isempty(readOnlypropObj)
                    return;
                end
                if strcmp(readOnlypropObj.value,'true')
                    propertyValue='false';
                end
            end

            if strcmp(propertyId,'Visible')
                hiddenpropObj=widget.getPropertyByKey('Hidden');
                if isempty(hiddenpropObj)
                    return;
                end
                if strcmp(hiddenpropObj.value,'true')
                    propertyValue='false';
                end
            end
        end


        function isPromotedParameter=getIsPromotedParameter(~,propertyMap,isParameter)
            isPromotedParameter=false;
            if isParameter&&strcmp(propertyMap.Type,'promote')
                isPromotedParameter=true;
            end
        end


        function widgetType=getWidgetTypefromClass(~,dialogControl,isParameter)
            if isParameter
                widgetType=lower(strrep(class(dialogControl),'Simulink.dialog.parameter.',''));
            else
                widgetType=lower(strrep(class(dialogControl),'Simulink.dialog.',''));
            end
        end


        function widget=createWidgetObjectforNewMask(this,type,parent,widgetId,name,prompt)

            widget=simulink.maskeditor.Widget(this.m_MF0Model,...
            struct('id',widgetId,'parent',parent));

            widget.widgetMetaData=simulink.maskeditor.WidgetMetaData(this.m_MF0Model,...
            struct('isPromotedParameter',false,'isParameter',false));

            propertiesForWidget=this.m_WidgetsPropertyData.widget_properties.(type);

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

                if i==1
                    aWidgetPropertiesArray=propertyObj;
                else
                    aWidgetPropertiesArray(end+1)=propertyObj;%#ok<AGROW>
                end
            end
            widget.properties=aWidgetPropertiesArray;
        end


        function populateBlockContextDetails(this)
            aBlockHdl=this.m_Context.blockHandle;
            aModelHdl=bdroot(aBlockHdl);

            modelMaskIndex=1;
            if this.m_Context.isMaskOnModel
                if strcmp(get_param(aModelHdl,'blockdiagramtype'),'subsystem')
                    modelMaskIndex=2;
                end
            end

            if this.m_Context.isMaskOnModel
                bIsMaskOnModelRef=this.isMaskOnModelRef(modelMaskIndex);
                bIsMaskOnSsref=this.isMaskOnSsref(modelMaskIndex);
                aFullPath=getfullname(aModelHdl);
            else
                bIsMaskOnModelRef=false;
                bIsMaskOnSsref=false;
                aFullPath=getfullname(aBlockHdl);
            end

            bBDIsLibrary=bdIsLibrary(aModelHdl);
            bCanChangePortRotate=builtin('_can_change_port_rotation',aBlockHdl);

            this.m_MEData.context=simulink.maskeditor.BlockContext(this.m_MF0Model,...
            struct(...
            'blockHandle',aBlockHdl,...
            'blockName',get_param(aBlockHdl,'Name'),...
            'blockType',get_param(aBlockHdl,'blockType'),...
            'blockFullPath',aFullPath,...
            'readOnly',this.m_Context.isReadOnly,...
            'maskOnMask',this.m_Context.isMaskOnMask,...
            'maskOnModel',this.m_Context.isMaskOnModel,...
            'maskOnModelRef',bIsMaskOnModelRef,...
            'maskOnSsref',bIsMaskOnSsref,...
            'maskOnSysObject',this.m_Context.isMaskOnSystemObject,...
            'bdIsLibrary',bBDIsLibrary,...
            'canChangePortRotate',bCanChangePortRotate,...
            'dialogTitle',this.m_Context.dialogTitle)...
            );
        end

        function isMaskOnModelRef=isMaskOnModelRef(~,modelMaskIndex)
            isMaskOnModelRef=modelMaskIndex==1;
        end

        function isMaskOnSsref=isMaskOnSsref(~,modelMaskIndex)
            isMaskOnSsref=modelMaskIndex==2;
        end

        function populateDocumentationDetails(this)
            mask=this.m_MaskObj;
            if~isempty(mask)
                this.m_MEData.documentation=simulink.maskeditor.Documentation(this.m_MF0Model,...
                struct('type',mask.Type,'description',mask.Description,'help',mask.Help));
            else
                this.m_MEData.documentation=simulink.maskeditor.Documentation(this.m_MF0Model);
            end
        end

        function populateIconProperties(this)
            mask=this.m_MaskObj;
            if~isempty(mask)
                this.m_MEData.icon=simulink.maskeditor.Icon(this.m_MF0Model,...
                struct('display',mask.Display,'imageFile',mask.ImageFile,'dvgIcon',mask.BlockDVGIcon));

                this.m_MEData.iconProperties=simulink.maskeditor.IconProperties(this.m_MF0Model,...
                struct('iconFrame',mask.IconFrame,'iconOpaque',mask.IconOpaque,...
                'runInitForIconRedraw',mask.RunInitForIconRedraw,'iconRotate',mask.IconRotate,...
                'portRotate',mask.PortRotate,'iconUnits',mask.IconUnits));
            else
                this.m_MEData.icon=simulink.maskeditor.Icon(this.m_MF0Model);
                this.m_MEData.iconProperties=simulink.maskeditor.IconProperties(this.m_MF0Model);
                if~this.m_MEData.context.canChangePortRotate&&~this.m_MEData.context.maskOnModel
                    this.m_MEData.iconProperties.portRotate=get_param(this.m_MEData.context.blockHandle,'PortRotationType');
                end
            end
        end



        function tableValue=getCustomTableValue(~,propertyMap)
            valueObject=struct('values','','columns','');

            valueStr=propertyMap.Value;
            columns=propertyMap.DialogControl.Columns;

            if(isempty(valueStr)||isempty(columns))
                tableValue=jsonencode(valueObject);
                return;
            end

            value=eval(valueStr);
            [numRows,numCols]=size(value);
            tableValueCellAray=cell(numRows,1);

            for i=1:numRows
                tableValueCellAray{i}=cell(numCols,1);
                for j=1:numCols
                    if(strcmpi(columns(j).Type,'checkbox'))
                        checked=strcmpi(value{i,j},'on');
                        tableValueCellAray{i}{j}.checked=checked;
                    else
                        tableValueCellAray{i}{j}=value{i,j};
                    end
                end
            end
            valueObject={};
            valueObject.values=tableValueCellAray;
            valueObject.columns=propertyMap.DialogControl.Columns;

            tableValue=jsonencode(valueObject);
        end

        function textAreaValueStr=getTextAreaValue(~,propertyMap)
            textAreaValueObject={};
            textAreaValueObject.value=propertyMap.Value;
            textAreaValueObject.textType=propertyMap.DialogControl.TextType;

            textAreaValueStr=jsonencode(textAreaValueObject);

        end





        function populateDTSParamsAssociationsFields(this,widgets)

            dtsParams=maskeditor.internal.Utils.findAllDataTypeStrParams(widgets);
            if isempty(dtsParams)
                return;
            end

            for i=1:length(dtsParams)
                typeOptionsValue=maskeditor.internal.Utils.getPropertyValue(dtsParams{i},'TypeOptions');

                typeOptionsValue=jsondecode(typeOptionsValue);
                association=typeOptionsValue.a;

                if~isempty(association)

                    dtsWidgetId=maskeditor.internal.Utils.getWidgetIdInModelForMaskParamIndex(widgets,association.DTSParamId,this.m_MaskObj);
                    editWidgetId=maskeditor.internal.Utils.getWidgetIdInModelForMaskParamIndex(widgets,association.EditWidget,this.m_MaskObj);
                    minWidgetId=maskeditor.internal.Utils.getWidgetIdInModelForMaskParamIndex(widgets,association.MinWidget,this.m_MaskObj);
                    maxWidgetId=maskeditor.internal.Utils.getWidgetIdInModelForMaskParamIndex(widgets,association.MaxWidget,this.m_MaskObj);

                    typeOptionsValue.a.DTSParamId=dtsWidgetId;
                    typeOptionsValue.a.EditWidget=editWidgetId;
                    typeOptionsValue.a.MinWidget=minWidgetId;
                    typeOptionsValue.a.MaxWidget=maxWidgetId;

                    typeOptionsValue=jsonencode(typeOptionsValue);


                    widget=maskeditor.internal.Utils.getWidgetFromWidgetCollection(widgets,dtsParams{i}.id);
                    widget.getPropertyByKey('TypeOptions').value=typeOptionsValue;
                end
            end
        end


        function ret=getTunablePopupOptionsValue(~,propValue)

            if(strcmpi(class(propValue),"Simulink.Mask.EnumerationTypeOptions"))
                ret.selectedRadio="enum";
                ret.value=propValue.ExternalEnumerationClass;
                ret.options={propValue.EnumerationMembers.DescriptiveName};
            else
                ret.selectedRadio="list";
                ret.value=propValue;
            end
        end

        function value=getListboxValue(~,propertyMap)
            try
                value=eval(propertyMap.Value);
                value=jsonencode(value);
            catch
                value="[]";
            end
        end

        function constraintId=getConstraintIdForPropertyEditor(this,propertyMap)
            constraintNameFromMask=propertyMap.ConstraintName;
            constraintId='';
            if isempty(constraintNameFromMask)
                return;
            end
            constraintManagerModel=this.m_MEData.constraintManagerTopObject;
            if isempty(constraintManagerModel)
                return;
            end

            if contains(constraintNameFromMask,':')
                splitted_constraintName=strsplit(constraintNameFromMask,':');
                matFileNameFromMask=splitted_constraintName{1};
                constraintNameFromMask=splitted_constraintName{2};
                isFileLoadedInModel=constraint_manager.ModelUtils.tryLoadingAssociatedMATFileToModel(...
                constraintManagerModel,matFileNameFromMask,this.m_MEInstance.m_ConstraintManagerInterface);
                if isFileLoadedInModel
                    constraintId=constraint_manager.ModelUtils.getSharedConstraintIdFromMATFile(constraintManagerModel,...
                    constraintNameFromMask,matFileNameFromMask);
                end
            else
                constraintId=constraint_manager.ModelUtils.getParameterConstraintId(constraintManagerModel,constraintNameFromMask);
            end

        end

        function createDefaultModelMask(this,aBlkHdl)
            aModelMaskObj=Simulink.Mask.get(aBlkHdl);
            aModelHdl=bdroot(aBlkHdl);

            this.populateBlockContextDetails();
            this.populateIconProperties();
            this.populateDocumentationDetails();
            this.createThreeDefaultsWidgets();

            aDefaultModelMaskInfo=Simulink.Mask.getDefaultModelMaskInfo(aModelHdl);

            if isempty(aModelMaskObj)
                aMaskEditor.setMaskType(aDefaultModelMaskInfo.Type);
                aMaskEditor.setMaskDescription(aDefaultModelMaskInfo.Description);
            end

            aModelArgs=[aDefaultModelMaskInfo.ModelParameterArguments;aDefaultModelMaskInfo.BlockParameterArguments];
            addDescAndParamGroup(aMaskEditor);

            aParent=[];
            aTreeRoot=aMaskEditor.getTreeTableList();
            if(2==aTreeRoot.size())
                aParent=aTreeRoot.get(1);
            end

            if isempty(aParent)
                aParent=aTreeRoot;
            end

            for i=1:length(aModelArgs)

                if(isempty(aModelMaskObj)||isempty(aModelMaskObj.getParameter(aModelArgs(i).Name)))
                    aParamElement=aMaskEditor.createItemForMaskStyle(aMaskEditor.getMaskStyle_Edit());

                    aParamRow=aMaskEditor.createRowFromItems(aMaskEditor,aParamElement);

                    aParamRow.setValueAt(aModelArgs(i).Name,aMaskEditor.getVarCol());
                    aParamRow.setValueAt(aModelArgs(i).Prompt,aMaskEditor.getPromptCol());
                    aParamRow.setValueAt(aModelArgs(i).Value,aMaskEditor.getValueCol());

                    aParent.addChild(aParamRow);
                end
            end
        end
    end
end

