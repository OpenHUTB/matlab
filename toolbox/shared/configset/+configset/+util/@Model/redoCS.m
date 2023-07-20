function redoCS(h,dlg)

    if~strcmp(h.Status,'Restored')
        return;
    end

    try
        h.Status='InProgress';
        h.setDlg(dlg);

        if isa(h.Diff,'DAStudio.Dialog')
            delete(h.Diff);
        end

        replaceConfigSet(h.Name,h.PostCS);

        h.Status='Converted';
        h.Fail=false;

        if h.GUI
            h.setDlg(dlg);
        end
    catch e
        h.Status='Restored';
        h.Fail=true;
        h.ErrMessage=e;
        if h.GUI
            h.setDlg(dlg);
        else
            disp(configset.util.message(e));
        end
    end
