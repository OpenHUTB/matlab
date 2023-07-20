function dlg=getDialogSchema(h,schemaName)




    dlg=[];

    hSrc=h.getSourceObject;

    if~isempty(hSrc)&&isa(hSrc,'Simulink.BaseConfig')
        try


            if isa(hSrc,'Simulink.ConfigSet')
                dlg=getConfigSetDialogSchema(h,schemaName);
            elseif isa(hSrc,'Simulink.ConfigSetRef')
                dlg=getConfigSetRefDialogSchema(h,schemaName);
            end
        catch ME




            dlg=configset.internal.util.errorDlg(ME);
            return;
        end
    end

    if~isempty(dlg)
        dlg.MinMaxButtons=true;
    end

