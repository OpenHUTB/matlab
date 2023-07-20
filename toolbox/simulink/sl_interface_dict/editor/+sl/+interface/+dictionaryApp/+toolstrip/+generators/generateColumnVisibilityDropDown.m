function generatedWidget=generateColumnVisibilityDropDown(cbinfo)





    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;

    generatedWidgetType=cbinfo.EventData.type;
    generatedWidgetId=cbinfo.EventData.namespace;
    generatedWidget=dig.GeneratedWidget(generatedWidgetId,generatedWidgetType);

    columnNames=guiObj.getColumnsForCurrentTab();
    visibleColumns=guiObj.getVisibleColumns();
    assert(~isempty(visibleColumns),'Visible columns should be initialized before the column visibility generator is called.')

    for i=1:length(columnNames)

        columnName=columnNames{i};
        toolType='ListItemWithCheckBox';
        columnToggle=generatedWidget.Widget.addChild(toolType,['toggleColumnsItem_',columnName]);


        action=createColumnVisibilityAction(generatedWidget,columnName,visibleColumns);
        columnToggle.ActionId=[generatedWidgetId,':',action.name];
    end
end

function action=createColumnVisibilityAction(generatedWidget,columnName,visibleColumns)
    actionId=['ColumnVisibility_',columnName,'_Action'];
    action=generatedWidget.createAction(actionId);
    action.text=columnName;
    if strcmp(columnName,'Name')

        action.enabled=false;
    else
        action.enabled=true;
    end
    if any(contains(visibleColumns,columnName))

        action.selected=true;
    else
        action.selected=false;
    end
    action.qabEligible=false;
    action.closePopupOnClick=false;
    action.setCallbackFromArray(...
    @(cbinfo)sl.interface.dictionaryApp.toolstrip.callbacks.toggleColumn(columnName,cbinfo),...
    dig.model.FunctionType.Action);
    action.eventDataType=dig.model.EventDataType.Boolean;
end


