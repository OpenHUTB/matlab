function updateDeps=OptimizationCustomizeCallback(cs,msg)




    adp=configset.internal.getConfigSetAdapter(cs);
    dlg=msg.dialog;
    if isa(dlg.getDialogSource,'configset.dialog.HTMLView')

        isHTML=true;
        dlg=ConfigSet.DDGWrapper(dlg);
    else
        isHTML=false;
    end

    updateDeps=true;


    if msg.value==0

        if isHTML
            dlg.disableDialog;
        end

        str=DAStudio.message('RTW:configSet:optClearCustomizationWarning');
        answer=questdlg(str,...
        DAStudio.message('RTW:configSet:optCustomizeWarningTitle'),...
        DAStudio.message('RTW:configSet:configSetDlgOKButton'),...
        DAStudio.message('RTW:configSet:configSetDlgCancelButton'),...
        DAStudio.message('RTW:configSet:configSetDlgOKButton'));

        if~strcmp(answer,DAStudio.message('RTW:configSet:configSetDlgOKButton'))
            updateDeps=false;
            if isHTML
                adp.refresh;
            else

                dlg.setWidgetValue('Tag_ConfigSet_Optimization_OptimizationCustomize',1);
            end
        end
        if isHTML
            dlg.enableDialog;
        end
    else

        name='optimizationLevels';
        layout=configset.internal.getConfigSetCategoryLayout;
        group=layout.getGroup(name);
        tag=group.Tag;
        dlg.expandTogglePanel(tag,true);
    end
end


