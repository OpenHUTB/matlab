function dlg=showDialog(h)

    h.GUI=true;
    if isa(h.Dialog,'DAStudio.Dialog')
        dlg=h.Dialog;
    else
        dlg=DAStudio.Dialog(h);
        h.Dialog=dlg;
    end

    dlg.show;
    dlg.setFocus('PB');