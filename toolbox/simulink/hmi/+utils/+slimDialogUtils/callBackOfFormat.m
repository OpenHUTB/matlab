function callBackOfFormat(dlg)


    selectedFormat=dlg.getComboBoxText('format');
    dlg.setEnabled('formatString',strcmp(selectedFormat,DAStudio.message('SimulinkHMI:dashboardblocks:CUSTOM')));
end