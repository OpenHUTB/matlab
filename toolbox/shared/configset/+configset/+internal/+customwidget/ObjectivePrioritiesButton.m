function updateDeps=ObjectivePrioritiesButton(~,msg)




    updateDeps=false;

    if~isempty(msg.dialog)
        hDlg=msg.dialog;
        dlgSource=hDlg.getDialogSource;
        if isa(dlgSource,'configset.dialog.HTMLView')
            hSrc=dlgSource.Source.getCS;
        else
            hSrc=dlgSource;
        end
        hController=hSrc.getDialogController;
        if isempty(hController.ObjectiveWindow)
            hController.ObjectiveWindow=Simulink.ConfigSetObjectives;
        end
        hController.ObjectiveWindow.view(hSrc);
    end
