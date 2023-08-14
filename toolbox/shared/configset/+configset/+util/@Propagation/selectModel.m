function selectModel(h,tag,val)

    mdl=tag(3:end);
    m=h.Map(mdl);
    m.select(val,h.Dialog);

    if h.GUI
        h.setDlg();
    end


