function closeAll(h)


    vs=h.Map.values;
    for i=1:length(vs)
        v=vs{i};
        if isa(v.Diff,'DAStudio.Dialog')
            delete(v.Diff);
        end
        try
            delete(v.ErrDlg);
        catch %#ok
        end
    end

    if h.Mode==1||h.Mode==2
        h.Mode=5;
    else
        h.stopProcess();
    end

    uisetpref('clearall');
