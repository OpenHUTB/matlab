function createDataTypeAssistantFlyout(dlg,tag,hDlgSource,dtName,dtPrompt,dtTag,dtVal,dtaItems,dtaOn)


































    openDlgs=DAStudio.ToolRoot.getOpenDialogs;
    for i=1:length(openDlgs)
        openDlg=openDlgs(i);
        if~isempty(openDlg.getTitle)&&strcmp(openDlg.getTitle,DAStudio.message('Simulink:dialog:UDTDataTypeAssistGrp'))
            return;
        end
    end


    h=Simulink.DataTypeAssistantDialog(dlg,hDlgSource,dtName,dtPrompt,dtTag,dtVal,dtaItems,dtaOn);
    h.showDialog(tag,dtTag);
end
