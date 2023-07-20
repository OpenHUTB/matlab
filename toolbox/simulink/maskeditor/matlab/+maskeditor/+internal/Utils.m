



classdef Utils

    properties(Constant)
        sCheckboxProperties={'Evaluate','ReadOnly','Hidden','NeverSave','Enabled','Visible','HorizontalStretch',...
        'AlignPrompts','ShowFilter','Multiselect','Sortable','ShowParameterName','Expand','WordWrap'};
    end

    methods(Access=public,Static)

        function isContainer=isContainer(obj)
            isContainer=isa(obj,'Simulink.dialog.Table')||isa(obj,'Simulink.dialog.Tab')||...
            isa(obj,'Simulink.dialog.Group')||isa(obj,'Simulink.dialog.CollapsiblePanel')||...
            isa(obj,'Simulink.dialog.Panel')||isa(obj,'Simulink.dialog.TabContainer');
        end


        function isDialogControl=isDialogControl(obj)
            isDialogControl=isa(obj,'Simulink.dialog.Text')||isa(obj,'Simulink.dialog.Hyperlink')||...
            isa(obj,'Simulink.dialog.Button')||isa(obj,'Simulink.dialog.ListboxControl')||...
            isa(obj,'Simulink.dialog.TreeControl')||isa(obj,'Simulink.dialog.LookupTableControl')||...
            isa(obj,'Simulink.dialog.Image');
        end

        function isCheckBoxProperty=isCheckBoxProperty(aProperty)
            isCheckBoxProperty=contains(aProperty,maskeditor.internal.Utils.sCheckboxProperties);
        end

        function widgetType=getTypeOfWidget(widgetObj)
            typeObj=widgetObj.getPropertyByKey('Type');
            widgetType=typeObj.value;
        end

        function propertyValue=getPropertyValue(widgetObj,propertyId)
            propObj=widgetObj.getPropertyByKey(propertyId);
            propertyValue=propObj.value;
        end



        function[widgetIdInModel]=getWidgetIdInModelForMaskParamIndex(widgets,paramIndexInMask,maskObj)
            widgetIdInModel='';
            if isempty(paramIndexInMask)
                return;
            end

            parameterName=maskObj.Parameters(str2double(paramIndexInMask)).Name;

            for i=1:widgets.Size()
                widgetObj=widgets(i);
                parameterNameFromModel=maskeditor.internal.Utils.getPropertyValue(widgetObj,'Name');
                if strcmp(parameterName,parameterNameFromModel)
                    widgetIdInModel=widgetObj.id;
                    break;
                end
            end
        end

        function dtsParamsObj=findAllDataTypeStrParams(widgets)
            dtsParamsObj={};
            for i=1:widgets.Size()
                widgetObj=widgets(i);
                propertyType=maskeditor.internal.Utils.getTypeOfWidget(widgetObj);
                if strcmp(propertyType,'datatypestr')||strcmp(propertyType,'unidt')
                    aPromotedParameterList=widgetObj.getPropertyByKey('PromotedParametersList');
                    if isempty(aPromotedParameterList)
                        dtsParamsObj{end+1}=widgetObj;%#ok<AGROW>
                    end
                end
            end
        end

        function ret=getWidgetFromWidgetCollection(widgets,widgetId)
            ret=[];
            for i=1:widgets.Size()
                if strcmpi(widgets(i).id,widgetId)
                    ret=widgets(i);
                    return;
                end
            end
        end


        function propertyValue=changeValueforJS(widgetType,propertyName,propertyValue)
            if maskeditor.internal.Utils.isCheckBoxProperty(propertyName)||(strcmp(widgetType,'checkbox')&&strcmp(propertyName,'Value'))
                propertyValue=maskeditor.internal.Utils.convertCheckBoxValueforJS(propertyValue);
            elseif strcmp(widgetType,'datatypestr')&&strcmp(propertyName,'TypeOptions')
                propertyValue=maskeditor.internal.Utils.convertDTSTypeOptionsForJS(propertyValue);
            elseif strcmp(propertyName,'TypeOptions')||strcmp(propertyName,'Prompt')||strcmp(propertyName,'Tooltip')
                propertyValue=jsonencode(propertyValue);
            elseif strcmp(widgetType,'treecontrol')&&strcmp(propertyName,'TreeItems')
                propertyValue=maskeditor.internal.Utils.convertTreeItemsforJS(propertyValue);
            elseif strcmp(widgetType,'customtable')&&strcmp(propertyName,'Columns')
                propertyValue=maskeditor.internal.Utils.convertCustomTableColumnsDataForJS(propertyValue);
            elseif strcmp(widgetType,'lookuptablecontrol')&&strcmp(propertyName,'Table')
                propertyValue=maskeditor.internal.Utils.convertLUTTableForJS(propertyValue);
            elseif strcmp(widgetType,'lookuptablecontrol')&&strcmp(propertyName,'Breakpoints')
                propertyValue=maskeditor.internal.Utils.convertLUTBreakpointsForJS(propertyValue);
            end
        end


        function propertyValue=convertCustomTableColumnsDataForJS(value)
            propertyValue=jsondecode(jsonencode(value));
            for i=1:length(propertyValue)
                propertyValue(i).Enabled=strcmpi(propertyValue(i).Enabled,'on');
                propertyValue(i).Visible=strcmpi(propertyValue(i).Visible,'on');
                propertyValue(i).Evaluate=strcmpi(propertyValue(i).Evaluate,'on');
            end
            propertyValue=jsonencode(propertyValue);
        end

        function propertyValue=convertDTSTypeOptionsForJS(value)
            typeOptions=value(6:end);
            closingBrackets=strfind(typeOptions,'}');
            dtsTypeOptions=struct("a",'',"i",'',"b",'',"s",'',"g",'',"u",'');
            nextStartIndex=5;
            nextFieldKey=typeOptions(3);
            for i=1:length(closingBrackets)
                strEndIndex=closingBrackets(i);
                str=typeOptions(nextStartIndex:strEndIndex-1);
                strValues=split(str,'|');
                if strcmp(nextFieldKey,"a")
                    dtsTypeOptions.a=struct('DTSParamId',strValues{1},...
                    'MinWidget',strValues{2},...
                    'MaxWidget',strValues{3},...
                    'EditWidget',strValues{4});
                else
                    dtsTypeOptions.(nextFieldKey)=strValues;
                end

                if i~=length(closingBrackets)
                    nextFieldKey=typeOptions(strEndIndex+2);
                    nextStartIndex=strEndIndex+4;
                end
            end

            propertyValue=jsonencode(dtsTypeOptions);
        end



        function treeItemsPropertyValue=convertTreeItemsforJS(value)
            treeNodesObject={};
            nodesCount=0;
            if strcmp(value,'{}')
                treeItemsPropertyValue='';
                return;
            end
            [treeItemsPropertyValue,~]=maskeditor.internal.Utils.parseTreeItems(value,'null',treeNodesObject,nodesCount);
            treeItemsPropertyValue=jsonencode(treeItemsPropertyValue);
        end



        function[treeNodesObject,nodesCount]=parseTreeItems(treeNode,parent,treeNodesObject,nodesCount)
            for i=1:length(treeNode)
                child=treeNode{i};
                currentParent=parent;
                if iscell(child)
                    parentForRecursion=treeNodesObject{nodesCount}.id;
                    [treeNodesObject,nodesCount]=maskeditor.internal.Utils.parseTreeItems(child,parentForRecursion,treeNodesObject,nodesCount);
                else
                    nodesCount=nodesCount+1;
                    nodeId=strcat('node',string(nodesCount));
                    treeNodesObject{end+1}=struct('id',nodeId,'label',child,'parent',currentParent);%#ok<AGROW>
                end
            end
        end


        function changedValue=convertCheckBoxValueforJS(value)
            changedValue='false';
            if strcmpi(value,'on')||strcmpi(value,'true')||(islogical(value)&&value)
                changedValue='true';
            end
        end

        function aTranslatedPrompt=getTranslatedText(aPrompt)
            try
                if contains(aPrompt,':')
                    aTranslatedPrompt=message(aPrompt).getString();
                    return;
                end
            catch
            end

            aTranslatedPrompt=aPrompt;
        end

        function value=convertLUTTableForJS(TableData)
            value.paramName=TableData.Name;
            value.unit=TableData.Unit;
            value.displayName=TableData.FieldName;
            value=jsonencode(value);
        end

        function value=convertLUTBreakpointsForJS(BPData)
            value=[];
            for i=1:length(BPData)
                value(i).paramName=BPData(i).Name;%#ok<AGROW>
                value(i).unit=BPData(i).Unit;%#ok<AGROW>
                value(i).displayName=BPData(i).FieldName;%#ok<AGROW>
            end
            value=jsonencode(value);
        end

    end
end