


function showDialog(FMU2ExpCSDialog)



    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    pmDlgs=dlgs.find('dialogTag','fmu2expcs_dialog');
    dlg=[];

    for i=1:length(pmDlgs)
        currentDlg=pmDlgs(i);
        if strcmp(FMU2ExpCSDialog.ModelName,...
            currentDlg.getDialogSource.ModelName)
            dlg=currentDlg;
            break;
        end
    end

    if isempty(dlg)
        dlg=DAStudio.Dialog(FMU2ExpCSDialog);
        dlg.show;
        FMU2ExpCSDialog.installModelCloseListener(dlg);




        FMU2ExpCSDialog.updatePackageListSpreadSheet(dlg);
    else
        dlg.show;
    end

end
