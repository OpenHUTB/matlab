function select(h,val,dlg)

    h.IsSelected=val;

    if h.GUI&&exist('dlg','var')
        if isa(dlg,'DAStudio.Dialog')
            dlg.setWidgetValue(strcat('c_',h.Name),val);
        end
    end