function undoModel(h,tag)

    h.Dirty=true;
    mdl=tag(3:end);
    m=h.Map(mdl);
    m.undoCS(h.Dialog);

    if h.GUI&&isa(h.Dialog,'DAStudio.Dialog')
        h.setDlg();
    end


