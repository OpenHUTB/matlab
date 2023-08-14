
function openCoSimSignalCompensationAdvancedDialog(this)

    src=Simulink.cosimservice.internal.CoSimSignalCompensationAdvancedDialog(this.inputPortsSource.selectedRow);
    Simulink.cosimservice.internal.CoSimSignalCompensationAdvancedDialog.opendlg(src);
end