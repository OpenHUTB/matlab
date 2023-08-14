





function eventTriggerPortChanged(dlg)
    m3iObj=dlg.getSource().getM3iObject();
    assert(~isempty(m3iObj));
    arExplorer=autosar.ui.utils.findExplorer(m3iObj.modelM3I);
    assert(~isempty(arExplorer));
    eventData=arExplorer.EventData;
    row=dlg.getSelectedTableRow('AutosarEventConfigurationTable');
    if row>=0
        index=autosar.ui.utils.getEventIndex(eventData,row,m3iObj.Name);
        assert(any(strcmp(eventData(index).EventType,...
        {autosar.ui.wizard.PackageString.EventTypes{2},...
        autosar.ui.wizard.PackageString.EventTypes{4},...
        autosar.ui.wizard.PackageString.EventTypes{6},...
        autosar.ui.wizard.PackageString.EventTypes{7}})));
        val=dlg.getWidgetValue('AutosarTriggerPort');
        triggerValue=i_comboBoxValueToEntry(...
        eventData(index).ReceiverCellValues,val);
        eventData(index).setTriggerPort(triggerValue);
        sigValue='';
        if val>0
            triggerValue=strsplit(triggerValue,'.');
            sigValue=autosar.ui.utils.getOpSignature(arExplorer,triggerValue(1),triggerValue(2),...
            m3iObj);
        end
        dlg.setWidgetValue('OperationSignatureEdit',sigValue);
    end
end

function entry=i_comboBoxValueToEntry(entries,value)

    entry=entries{value+1};
end
