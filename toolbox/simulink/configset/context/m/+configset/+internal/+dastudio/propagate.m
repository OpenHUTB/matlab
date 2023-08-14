function propagate(cs)




    persistent dlg


    if isa(dlg,'DAStudio.Dialog')
        errordlg(DAStudio.message('configset:util:SingleInstancePropagationDialog'));
        return
    end

    csme=configset.util.Propagation(get_param(cs.getModel,'Name'),'gui');
    dlg=csme.Dialog;
