function out=getHTMLView(src)













    out=[];

    if~isempty(src)
        if isa(src,'Simulink.ConfigSetRef')&&...
            slfeature('ConfigSetRefOverride')==0
            out=src.getDialogController.csv2;
        else
            dlg=src.getDialogHandle;
            if isa(dlg,'DAStudio.Dialog')
                out=dlg.getDialogSource;
            end
        end
    end
