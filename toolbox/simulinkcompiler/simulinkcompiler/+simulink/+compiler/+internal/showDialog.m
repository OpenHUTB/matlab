


function showDialog(genAppDialog)



    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    genAppDlgs=dlgs.find('dialogTag','genapp_dialog');
    dlg=[];

    for dlgIndex=1:length(genAppDlgs)
        currentDlg=genAppDlgs(dlgIndex);
        if strcmp(genAppDialog.ModelName,...
            currentDlg.getDialogSource.ModelName)
            dlg=currentDlg;
            break;
        end
    end

    if isempty(dlg)
        dlg=DAStudio.Dialog(genAppDialog);
    end

    dlg.show;
end