function showReport(pkgFile)




    dialogs=DAStudio.ToolRoot.getOpenDialogs();
    scDialogs=dialogs.find('dialogTag','simulinkCache_dialog');
    for i=1:length(scDialogs)
        currentDialog=scDialogs(i);
        dialogSource=currentDialog.getDialogSource();

        if strcmp(pkgFile,dialogSource.MyPkgFile)
            currentDialog.delete();
            break;
        end
    end


    a=Simulink.packagedmodel.Report(pkgFile);
    dlg=DAStudio.Dialog(a);
    dlg.show();
end