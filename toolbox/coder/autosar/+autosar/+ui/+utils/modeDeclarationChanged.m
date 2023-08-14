





function modeDeclarationChanged(dlg,~,modeIndex)

    m3iObj=dlg.getSource().getM3iObject();
    assert(~isempty(m3iObj));
    arExplorer=autosar.ui.utils.findExplorer(m3iObj.modelM3I);
    assert(~isempty(arExplorer));
    eventData=arExplorer.EventData;
    row=dlg.getSelectedTableRow('AutosarEventConfigurationTable');
    index=autosar.ui.utils.getEventIndex(eventData,row,m3iObj.Name);
    assert(strcmp(eventData(index).EventType,autosar.ui.wizard.PackageString.EventTypes{3}));
    val=dlg.getWidgetValue(['AutosarModeDeclarationRef',modeIndex]);
    switch modeIndex
    case{'1','2','3'}
        modeDeclaration=i_comboBoxValueToEntry(eventData(index).ModeDeclarationCellValues1,val);
        eventData(index).setModeDeclaration1(modeDeclaration);
    case '4'
        modeDeclaration=i_comboBoxValueToEntry(eventData(index).ModeDeclarationCellValues2,val);
        eventData(index).setModeDeclaration2(modeDeclaration);
    end
    arExplorer.EventData=eventData;
    arExplorer.SelectedEventName=eventData(index).Name;
    dlg.refresh;
end

function entry=i_comboBoxValueToEntry(entries,value)

    entry=entries{value+1};
end
