function restore(h)

    try
        h.Dirty=true;
        h.Mode=2;
        if h.GUI&&isa(h.Dialog,'DAStudio.Dialog');
            h.searchClear();
            h.setDlg();
        end

        vs=h.Map.values;
        for i=1:length(vs)
            pause(0.1);
            if h.Mode>2
                break;
            end
            v=vs{i};
            v.undoCS(h.Dialog);

            if h.GUI
                h.setDlg();
            end
        end

        if h.Mode~=4
            h.Mode=0;
        end

        if h.GUI&&isa(h.Dialog,'DAStudio.Dialog');
            h.setDlg();
        end

        h.save();
    catch e
        h.save();
        msg=configset.util.message(e);
        if h.GUI
            errordlg(msg);
        else
            error(msg);
        end
    end
