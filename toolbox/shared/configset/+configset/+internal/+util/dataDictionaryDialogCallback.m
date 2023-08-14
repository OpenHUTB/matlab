function[successful,errmsg]=dataDictionaryDialogCallback(hController,action)



    successful=true;
    errmsg='';
    dlg=[];


    if~isempty(hController.DataDictionary)
        source=hController.getSourceObject;

        if isa(source,'Simulink.ConfigSetRef')
            source=source.getRefObject(true);
        end
        if isa(source,'Simulink.ConfigSet')
            dlg=source.getDialogHandle;
        end
    end


    if isa(dlg,'DAStudio.Dialog')
        switch action
        case 'apply'
            if dlg.hasUnappliedChanges
                dlg.apply;
            end
        case 'revert'
            dlg.enableApplyButton(false);
            dlg.delete;
        end
    end
