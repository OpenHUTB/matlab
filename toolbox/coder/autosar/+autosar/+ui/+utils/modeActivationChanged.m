





function modeActivationChanged(dlg,~)

    m3iObj=dlg.getSource().getM3iObject();
    assert(~isempty(m3iObj));
    arExplorer=autosar.ui.utils.findExplorer(m3iObj.modelM3I);
    assert(~isempty(arExplorer));
    eventData=arExplorer.EventData;
    row=dlg.getSelectedTableRow('AutosarEventConfigurationTable');
    index=autosar.ui.utils.getEventIndex(eventData,row,m3iObj.Name);
    assert(strcmp(eventData(index).EventType,autosar.ui.wizard.PackageString.EventTypes{3}));
    val=dlg.getWidgetValue('AutosarModeActivationKind');
    eventData(index).setActivation(i_comboBoxValueToEntry(...
    eventData(index).ActivationCellValues,val));
    if~strcmp(eventData(index).ModeReceiverPort,DAStudio.message('RTW:autosar:selectERstr'))
        eventData(index).setModeDeclarationCellValues2(eventData(index).ModeDeclarationCellValues1);
    end
    arExplorer.EventData=eventData;
    arExplorer.SelectedEventName=eventData(index).Name;
    dlg.refresh;
end

function entry=i_comboBoxValueToEntry(entries,value)

    entry=entries{value+1};
end


