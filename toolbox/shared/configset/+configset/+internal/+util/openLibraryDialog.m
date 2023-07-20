function openLibraryDialog(cs,type)





    if slfeature('ConfigSetLibWeb')
        dlg=cs.getDialogHandle;
        if isa(dlg,'DAStudio.Dialog')

            if type=="Sim"
                configset.showParameterGroup(cs,{'Simulation Target'});
            elseif type=="RTW"
                configset.showParameterGroup(cs,{'Custom Code'});
            end
        else
            if type=="Sim"
                cs.CurrentDlgPage='Simulation Target';
            elseif type=="RTW"
                cs.CurrentDlgPage='Custom Code';
            end
            cs.view();
        end

    else

        if type=="Sim"
            cs.CurrentDlgPage='Simulation Target';
        elseif type=="RTW"
            cs.CurrentDlgPage='Code Generation/Custom Code';
        end
        cs.view();
        dlg=cs.getDialogHandle;
        if~isempty(dlg)&&isa(dlg,'DAStudio.Dialog')
            dlg.refresh();
            dlg.show();
        end
    end


