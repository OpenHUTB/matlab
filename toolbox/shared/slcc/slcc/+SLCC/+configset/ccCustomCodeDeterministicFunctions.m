function updateDeps=ccCustomCodeDeterministicFunctions(~,msg)


    updateDeps=false;

    hParentDlg=msg.dialog;
    if isempty(hParentDlg)
        return;
    end

    dlgSource=hParentDlg.getDialogSource;
    if isa(dlgSource,'Simulink.SFSimCC')
        hCompSrc=dlgSource;
        hCSSrc=hCompSrc.getConfigSet();
    else
        if isa(dlgSource,'configset.dialog.HTMLView')
            hCSSrc=dlgSource.Source.getCS;
        else
            hCSSrc=dlgSource;
        end
        if isa(hCSSrc,'Simulink.ConfigSet')
            hCompSrc=hCSSrc.getComponent('Simulation Target');
        end
    end

    hController=hCSSrc.getDialogController();
    uIDlgSrc=hController.CustomCodeDeterministicFunctionsDialog;

    if(isempty(uIDlgSrc)||...
        ~isa(uIDlgSrc,"SLCC.configset.deterministicFunctions.DeterministicFunctionsUI")||...
        ~isa(uIDlgSrc.thisDlg,'DAStudio.Dialog'))
        uIDlgSrc=openDeterministicFunctionsDialog(hCompSrc,hParentDlg);
        hController.CustomCodeDeterministicFunctionsDialog=uIDlgSrc;
    end

    uIDlgSrc.thisDlg.show();
    uIDlgSrc.parentDlg=hParentDlg;
    uIDlgSrc.csCompSrc=hCompSrc;
    uIDlgSrc.configSet=hCSSrc;
    uIDlgSrc.refreshFunctionSuggestions()
end

function uISrc=openDeterministicFunctionsDialog(hCompSrc,hParentDlg)
    import SLCC.configset.deterministicFunctions.DeterministicFunctionsUI.*;
    uISrc=SLCC.configset.deterministicFunctions.DeterministicFunctionsUI(hParentDlg,hCompSrc);
    uIDlg=DAStudio.Dialog(uISrc);
    uISrc.thisDlg=uIDlg;
    uIDlg.connect(hParentDlg,'up');
end