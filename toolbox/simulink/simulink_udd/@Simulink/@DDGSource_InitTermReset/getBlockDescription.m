function[descGrp,unknownBlockFound]=getBlockDescription(~,eventType)
    unknownBlockFound=false;
    switch eventType
    case 'Reset'
        descTxt.Name=DAStudio.message('Simulink:dialog:ResetSubsystemDescription');
        descGrp.Name='Reset Function';
    case 'Reinitialize'
        descTxt.Name=DAStudio.message('Simulink:dialog:ReinitializeSubsystemDescription');
        descGrp.Name='Reinitialize Function';
    case 'Initialize'
        descTxt.Name=DAStudio.message('Simulink:dialog:InitializeSubsystemDescription');
        descGrp.Name='Initialize Function';
    case 'Terminate'
        descTxt.Name=DAStudio.message('Simulink:dialog:TerminateSubsystemDescription');
        descGrp.Name='Terminate Function';
    case 'Broadcast'
        descTxt.Name=DAStudio.message('Simulink:dialog:MessageFunctionSubsystemDescription');
        descGrp.Name='Message Function';
    case 'Message Arrival'
        descTxt.Name=DAStudio.message('Simulink:dialog:MessageFunctionSubsystemDescription');
        descGrp.Name='Message Function';
    otherwise
        unknownBlockFound=true;
    end

    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];
end
