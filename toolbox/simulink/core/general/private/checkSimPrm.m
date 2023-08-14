function continueProcess=checkSimPrm(hCS)




    continueProcess=true;
    hDlg=hCS.getDialogHandle;
    if~isempty(hDlg)&&isa(hDlg,'DAStudio.Dialog')
        if hDlg.hasUnappliedChanges
            question=getString(message('RTW:configSet:configSetPromptDlg_Msg'));
            title_cp=getString(message('RTW:configSet:configSetPromptDlg_TitleStrMain'));
            title_str_active=getString(message('RTW:configSet:configSetPromptDlg_TitleStrActive'));
            title_str_inactive=getString(message('RTW:configSet:configSetPromptDlg_TitleStrInactive'));

            apply=getString(message('RTW:configSet:configSetPromptDlg_ApplyButton'));
            discard=getString(message('RTW:configSet:configSetPromptDlg_DiscardButton'));
            cancel=getString(message('RTW:configSet:configSetPromptDlg_CancelButton'));
            if isempty(hCS.getModel)
                title_state=[hCS.Name];
            else
                mdlName=get_param(hCS.getModel,'Name');
                if hCS.isActive
                    title_state=[mdlName,'/',hCS.Name,' ',title_str_active];
                else
                    title_state=[mdlName,'/',hCS.Name,' ',title_str_inactive];
                end
            end
            title=[title_cp,' ',title_state];

            featureVal=mfeatures('Get','TestCheckSimPrm');
            switch featureVal
            case 1
                choice=apply;
            case 2
                choice=discard;
            case 3
                choice=cancel;
            otherwise
                choice=questdlg(question,title,apply,discard,cancel,apply);


                drawnow;
            end

            switch(choice)
            case apply


                if~isempty(hDlg)&&isa(hDlg,'DAStudio.Dialog')
                    hDlg.apply;
                end
                continueProcess=true;
            case discard


                if~isempty(hDlg)&&isa(hDlg,'DAStudio.Dialog')
                    delete(hDlg);
                end
                continueProcess=true;
            case{cancel,''}
                continueProcess=false;
            otherwise
                error('M-assert');
            end
        end
    end
