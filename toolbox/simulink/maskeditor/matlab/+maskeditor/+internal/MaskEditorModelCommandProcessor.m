classdef MaskEditorModelCommandProcessor



    properties
MaskEditorModel
WidgetsPropertyData
Utils
    end

    methods
        function obj=MaskEditorModelCommandProcessor(maskeditormodel)
            obj.MaskEditorModel=maskeditormodel;
            obj.WidgetsPropertyData=jsondecode(fileread([matlabroot,'/toolbox/simulink/maskeditor/matlab/data/WidgetsPropertyData.json']));
            obj.Utils=maskeditor.internal.Utils();
        end



        function processCommand(this,commandData)
            commandAction=commandData.eventType;
            try
                switch commandAction
                case 'WidgetPropertyChanged'
                    this.processWidgetPropertyChanged(commandData);
                case 'WidgetAdded'
                    this.processAddWidget(commandData);
                case 'WidgetDeleted'
                    this.processDeleteWidget(commandData);
                case 'NewMaskedBlockImported'
                    this.processImportNewMaskedBlock(commandData);
                end
            catch exception
                throw(exception);
            end
        end



        function processImportNewMaskedBlock(this,commandData)
            libName=split(commandData.importedBlockPath,'/');
            load_system(libName{1});
            mask=get_param(commandData.importedBlockPath,"maskobject");
            DataModelElements=this.MaskEditorModel.DataModel.topLevelElements;
            transaction=this.MaskEditorModel.DataModel.beginRevertibleTransaction;
            for i=1:length(DataModelElements)
                DataModelElements(i).destroy;
            end
            this.MaskEditorModel.importMaskInDataModel(mask);
            transaction.commit('maskimported');

        end




        function processPromotedParameterDeletion(this,widgetsGettingDeletedObj)
            blocksppdata=this.MaskEditorModel.MEData.blockPromotableData;

            for i=1:length(widgetsGettingDeletedObj)

                widgetObj=widgetsGettingDeletedObj(i);

                isPromotedParameter=widgetObj.widgetMetaData.isPromotedParameter;

                if(isPromotedParameter)
                    ppListValue=this.Utils.getPropertyValue(widgetObj,'PromotedParametersList');
                    ppListValue=jsondecode(ppListValue);
                    for j=1:length(ppListValue)
                        ppId=ppListValue{j};
                        ppObj=blocksppdata.getByKey(ppId);
                        ppObj.hasBeenPromoted=false;
                    end
                end
            end
        end



        function removeAssocationFromDataTypeParamIfAny(this,widgetsGettingDeletedObj)

            dtsParams=this.Utils.findAllDataTypeStrParams(this.MaskEditorModel.MEData.Widgets);
            if isempty(dtsParams)
                return;
            end

            widgets=this.MaskEditorModel.MEData.Widgets;

            for i=1:length(widgetsGettingDeletedObj)

                widgetType=this.Utils.getTypeOfWidget(widgetsGettingDeletedObj(i));

                if ismember(widgetType,['edit','min','max'])


                    for j=1:length(dtsParams)

                        dtsParamObj=dtsParams{j};




                        if dtsParamObj.widgetMetaData.isPromotedParameter
                            continue;
                        end

                        dtsTypeOptionsValue=this.Utils.getPropertyValue(dtsParamObj,'TypeOptions');
                        dtsTypeOptionsValue=jsondecode(dtsTypeOptionsValue);

                        propertyNameInAssociations='EditWidget';
                        switch widgetType
                        case 'min'
                            propertyNameInAssociations='MinWidget';
                        case 'max'
                            propertyNameInAssociations='MaxWidget';
                        end

                        if~isempty(dtsTypeOptionsValue)&&isfield(dtsTypeOptionsValue.a,propertyNameInAssociations)


                            if strcmp(dtsTypeOptionsValue.a.(propertyNameInAssociations),widgetsGettingDeletedObj(i).id)

                                dtsTypeOptionsValue.a.(propertyNameInAssociations)='';

                                widgets.getByKey(dtsParamObj.id).properties.getByKey('TypeOptions').value=jsonencode(dtsTypeOptionsValue);
                            end
                        end
                    end
                end
            end
        end




        function processDeleteWidget(this,commandData)

            widgetsToDelete=this.getWidgetsToDelete(commandData.widgetId);

            widgets=this.MaskEditorModel.MEData.Widgets;

            widgetsToDeleteObj=cellfun(@(id)widgets.getByKey(id),widgetsToDelete);


            transaction=this.MaskEditorModel.DataModel.beginRevertibleTransaction;

            for i=1:length(widgetsToDelete)
                this.MaskEditorModel.MEData.Widgets.remove(widgetsToDeleteObj(i));

            end



            this.processPromotedParameterDeletion(widgetsToDeleteObj);



            this.removeAssocationFromDataTypeParamIfAny(widgetsToDeleteObj);

            transaction.commit('WidgetDeleted');

        end


        function associateDataTypeIfApplicable(this,addedWidgetsInfo,addedWidgets)
            if isfield(addedWidgetsInfo,'args')
                args=addedWidgetsInfo.args;
                if strcmp(args.subEvent,'AssociateDataType')
                    minWidgetId=addedWidgets(1).id;
                    maxWidgetId=addedWidgets(2).id;
                    dtsWidgetId=addedWidgets(3).id;
                    editWidgetId=args.editWidgetId;

                    widgets=this.MaskEditorModel.MEData.Widgets;
                    dtsProperties=widgets.getByKey(dtsWidgetId).properties;
                    dtsTypeOptionsObj=dtsProperties.getByKey('TypeOptions');
                    dtsTypeOptionsValue=jsondecode(dtsTypeOptionsObj.value);
                    dtsTypeOptionsValue.a=struct('DTSParamId',dtsWidgetId,'MinWidget',minWidgetId,...
                    'MaxWidget',maxWidgetId,'EditWidget',editWidgetId);

                    widgets.getByKey(dtsWidgetId).properties.getByKey('TypeOptions').value=jsonencode(dtsTypeOptionsValue);
                end
            end
        end



        function processAddWidget(this,commandData)

            addedWidgetsInfo=commandData.addedWidgetInfo;
            addedWidgets=addedWidgetsInfo.addedWidgets;

            common_properties=this.WidgetsPropertyData.common_properties;


            transaction=this.MaskEditorModel.DataModel.beginRevertibleTransaction;

            for i=1:length(addedWidgets)
                widgetId=addedWidgets(i).id;
                widgetName=addedWidgets(i).Name;
                widgetPrompt=addedWidgets(i).Prompt;

                if isstruct(addedWidgets(i).Type)
                    widgetType=addedWidgets(i).Type.type;
                else
                    widgetType=addedWidgets(i).Type;
                end

                widgetParentId=addedWidgets(i).parent;


                if isempty(widgetParentId)
                    widgetParentId='null';
                end

                propertiesForWidget=this.WidgetsPropertyData.widget_properties.(widgetType);

                newWidget=simulink.maskeditor.maskeditormodel.Widget(this.MaskEditorModel.DataModel,...
                struct('id',widgetId,'parent',widgetParentId));

                newWidget.widgetMetaData=simulink.maskeditor.maskeditormodel.WidgetMetaData(this.MaskEditorModel.DataModel,...
                struct('isPromotedParameter',false,'isParameter',false));

                for j=1:length(propertiesForWidget)
                    property=propertiesForWidget{j};

                    if isstruct(propertiesForWidget{j})
                        propertyData=propertiesForWidget{j};
                    else
                        propertyData=common_properties.(property);
                    end

                    if strcmp(propertyData.propertyId,'Name')
                        propertyValue=widgetName;
                    elseif strcmp(propertyData.propertyId,'Type')
                        propertyValue=widgetType;
                    elseif strcmp(propertyData.propertyId,'Prompt')
                        propertyValue=jsonencode(widgetPrompt);
                    elseif strcmp(propertyData.propertyId,'FilePath')
                        propertyValue='';
                    elseif strcmp(propertyData.propertyId,'TreeItems')
                        propertyValue='';
                    elseif strcmp(propertyData.propertyId,'Tooltip')
                        propertyValue=propertyData.defaultValue;
                        propertyValue=jsonencode(struct('textId',propertyValue,'text',this.Utils.getTranslatedText(propertyValue)));
                    else
                        propertyValue=propertyData.defaultValue;
                    end

                    if isstruct(propertyValue)
                        propertyValue=jsonencode(propertyValue);
                    end

                    propertyObj=simulink.maskeditor.maskeditormodel.Property(this.MaskEditorModel.DataModel,...
                    struct('widgetId',widgetId,...
                    'id',propertyData.propertyId,...
                    'value',string(propertyValue),...
                    'type',propertyData.type));

                    newWidget.properties.add(propertyObj);
                end

                this.MaskEditorModel.MEData.Widgets.add(newWidget);
            end



            this.associateDataTypeIfApplicable(addedWidgetsInfo,addedWidgets);


            transaction.commit('WidgetAdded');

        end




        function handleChangeInReadOnlyAndHidden(~,propertyId,propertiesObj)
            if strcmp(propertyId,'ReadOnly')||strcmp(propertyId,'Hidden')

                if strcmp(propertiesObj.getByKey(propertyId).value,'true')
                    if strcmp(propertyId,'ReadOnly')
                        propIdToUpdate='Enabled';
                    elseif strcmp(propertyId,'Hidden')
                        propIdToUpdate='Visible';
                    end
                    propertiesObj.getByKey(propIdToUpdate).value='false';
                end
            end
        end



        function processWidgetPropertyChanged(this,commandData)
            widgetId=commandData.widgetId;
            widgetType=commandData.widgetType;
            propertyId=commandData.propertyId;
            newPropertyValue=commandData.newPropertyValue;

            if strcmp(propertyId,'Type')
                this.handleChangeInTypeProperty(widgetId,newPropertyValue,widgetType);
                return;
            end

            if strcmp(propertyId,'Prompt')||strcmp(propertyId,'Tooltip')
                newPropertyValue.text=this.Utils.getTranslatedText(newPropertyValue.textId);
            end

            if isstruct(newPropertyValue)||iscell(newPropertyValue)

                if strcmp(propertyId,'TreeItems')&&length(newPropertyValue)==1
                    newPropertyValue={newPropertyValue};
                end
                newPropertyValue=jsonencode(newPropertyValue);
            end

            widgets=this.MaskEditorModel.MEData.Widgets;

            if~isempty(widgets.getByKey(widgetId))
                properties=widgets.getByKey(widgetId).properties;


                transaction=this.MaskEditorModel.DataModel.beginRevertibleTransaction;

                widgets.getByKey(widgetId).properties.getByKey(propertyId).value=newPropertyValue;

                this.handleChangeInReadOnlyAndHidden(propertyId,properties);

                transaction.commit('PropertyChanged');

            end
        end



        function handleChangeInTypeProperty(this,widgetId,newWidgetType,oldWidgetType)
            if strcmp(newWidgetType,'groupbox')
                newWidgetType='group';
            elseif strcmp(newWidgetType,'unidt')
                newWidgetType='datatypestr';
            end

            if strcmp(newWidgetType,oldWidgetType)
                return;
            end

            widgets=this.MaskEditorModel.MEData.Widgets;

            previousWidgetTypeProperties=widgets.getByKey(widgetId).properties;

            common_properties=this.WidgetsPropertyData.common_properties;
            propertiesForNewWidget=this.WidgetsPropertyData.widget_properties.(newWidgetType);


            transaction=this.MaskEditorModel.DataModel.beginRevertibleTransaction;

            if~isempty(widgets.getByKey(widgetId))


                propertyKeys=previousWidgetTypeProperties.keys();

                map=containers.Map('KeyType','char','ValueType','any');

                for i=1:length(propertyKeys)
                    propertyObj=previousWidgetTypeProperties.getByKey(propertyKeys{i});
                    if~isempty(propertyObj)
                        map(propertyKeys{i})=propertyObj.value;
                        widgets.getByKey(widgetId).properties.remove(propertyObj);
                    end
                end




                for j=1:length(propertiesForNewWidget)
                    property=propertiesForNewWidget{j};

                    if isstruct(propertiesForNewWidget{j})
                        propertyData=propertiesForNewWidget{j};
                    else
                        propertyData=common_properties.(property);
                    end

                    propertyId=propertyData.propertyId;

                    propertyValue=this.getPropertyValueFromOldPropertiesIfPresent(map,...
                    oldWidgetType,newWidgetType,propertyId,propertyData);

                    propertyObj=simulink.maskeditor.maskeditormodel.Property(this.MaskEditorModel.DataModel,...
                    struct('widgetId',widgetId,'id',propertyId,...
                    'value',propertyValue,'type',propertyData.type));

                    widgets.getByKey(widgetId).properties.add(propertyObj);

                end

                transaction.commit('TypePropertyChanged');

            end
        end







        function propertyValue=getPropertyValueFromOldPropertiesIfPresent(this,previousPropertyObjectMap,...
            oldWidgetType,newWidgetType,propertyId,propertyData)

            if~isKey(previousPropertyObjectMap,propertyId)||strcmp(propertyId,'Value')||...
                (strcmp(oldWidgetType,'datatypestr')&&strcmp(propertyId,'TypeOptions'))
                if strcmp(propertyId,'Prompt')
                    promptId=string(propertyData.defaultValue);
                    propertyValue=jsonencode(struct('textId',promptId,'text',this.Utils.getTranslatedText(promptId)));
                else
                    propertyValue=string(propertyData.defaultValue);
                end

            elseif strcmp(propertyId,'Type')
                propertyValue=newWidgetType;
            else
                propertyValue=previousPropertyObjectMap(propertyId);
            end
        end




        function queue=getWidgetsToDelete(this,deletedWidgetId)
            queue={deletedWidgetId};
            currentIndex=1;
            widgets=this.MaskEditorModel.MEData.Widgets;

            while currentIndex<=length(queue)

                currentWidgetId=queue{currentIndex};

                widgetKeys=widgets.keys();
                for i=1:length(widgetKeys)
                    widgetObj=widgets.getByKey(widgetKeys{i});
                    if strcmp(widgetObj.parent,currentWidgetId)
                        queue{end+1}=widgetObj.id;
                    end
                end
                currentIndex=currentIndex+1;
            end
        end


    end
end

