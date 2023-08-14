function selectAll(h,val)

    vs=h.Map.values;
    for i=1:length(vs)
        v=vs{i};
        v.select(val,h.Dialog);
    end

    if h.GUI
        h.setDlg();
    end
