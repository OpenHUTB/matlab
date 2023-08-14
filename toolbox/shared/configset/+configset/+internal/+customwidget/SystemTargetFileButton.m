function updateDeps=SystemTargetFileButton(cs,msg)




    updateDeps=false;

    hDlg=msg.dialog;
    if~isempty(hDlg)
        dlgSource=hDlg.getDialogSource;
        if isa(dlgSource,'configset.dialog.HTMLView')
            hSrc=dlgSource.Source.getCS;
        else
            hSrc=dlgSource;
        end
        configset.internal.util.launchSTFBrowser(hSrc,hDlg);
    end
