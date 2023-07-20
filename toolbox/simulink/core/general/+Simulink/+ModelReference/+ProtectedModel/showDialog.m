


function showDialog(protectedModelCreatorDialog)



    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    pmDlgs=dlgs.find('dialogTag','protectedMdl_dialog');
    dlg=[];

    for i=1:length(pmDlgs)
        currentDlg=pmDlgs(i);
        if strcmp(protectedModelCreatorDialog.ModelName,...
            currentDlg.getDialogSource.ModelName)
            dlg=currentDlg;
            break;
        end
    end

    if isempty(dlg)
        dlg=DAStudio.Dialog(protectedModelCreatorDialog);
        dlg.show;
        protectedModelCreatorDialog.installModelCloseListener(dlg);
    else
        dlg.show;
    end

end
