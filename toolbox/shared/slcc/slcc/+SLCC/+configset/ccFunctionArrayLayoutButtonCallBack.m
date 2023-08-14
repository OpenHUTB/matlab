function updateDeps=ccFunctionArrayLayoutButtonCallBack(~,msg)


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
    majorityUIDlgSrc=hController.FunctionArrayLayoutDialog;

    if(isempty(majorityUIDlgSrc)||...
        ~isa(majorityUIDlgSrc,"SLCC.configset.functionmajority.FunctionMajorityUI")||...
        ~isa(majorityUIDlgSrc.thisDlg,'DAStudio.Dialog'))
        majorityUIDlgSrc=loc_launch_function_majority_dialog(hCompSrc,hParentDlg);
        hController.FunctionArrayLayoutDialog=majorityUIDlgSrc;
    end

    majorityUIDlgSrc.thisDlg.show();
    majorityUIDlgSrc.parentDlg=hParentDlg;
    majorityUIDlgSrc.csCompSrc=hCompSrc;
    majorityUIDlgSrc.configSet=hCSSrc;
    majorityUIDlgSrc.refreshFunctionSuggestions();
end

function majorityUISrc=loc_launch_function_majority_dialog(hCompSrc,hParentDlg)
    import SLCC.configset.functionmajority.FunctionMajorityUI;
    majorityUISrc=SLCC.configset.functionmajority.FunctionMajorityUI(hParentDlg,hCompSrc);
    majorityUIDlg=DAStudio.Dialog(majorityUISrc);
    majorityUISrc.thisDlg=majorityUIDlg;
    majorityUIDlg.connect(hParentDlg,'up');
end