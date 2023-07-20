



function deleteEventFromTable(dlg,obj)
    arExplorer=autosar.ui.utils.findExplorer(obj.M3iObject.modelM3I);
    assert(~isempty(arExplorer));

    eventData=arExplorer.EventData;
    selRow=dlg.getSelectedTableRow('AutosarEventConfigurationTable');
    selEventName=dlg.getTableItemValue('AutosarEventConfigurationTable',...
    selRow,1);
    for index=1:length(eventData)
        if strcmp(eventData(index).Name,selEventName)&&...
            strcmp(eventData(index).RunnableName,obj.Name)
            eventData(index).delete;
            eventData(index)=[];
            break;
        end
    end
    arExplorer.EventData=eventData;
    dlg.refresh;
    dlg.enableApplyButton(true);
end
