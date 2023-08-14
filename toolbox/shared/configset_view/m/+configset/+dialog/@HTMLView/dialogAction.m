function dialogAction(obj,action)





    dlg=obj.Dlg;

    switch action
    case 'OK'
        ret=obj.apply(dlg);
        if ret
            obj.close(dlg,'ok');
            if isa(dlg,'DAStudio.Dialog')
                delete(dlg);
            end
        end
    case 'Cancel'
        obj.close(dlg,'cancel');
        if isa(dlg,'DAStudio.Dialog')
            delete(dlg);
        end
    case 'Help'
        obj.helpButton(dlg);
    case 'Apply'
        obj.apply(dlg);
    end

