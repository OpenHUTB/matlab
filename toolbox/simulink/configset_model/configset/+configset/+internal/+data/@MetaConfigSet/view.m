function dlg=view(obj)



    if isa(obj.Dlg,'DASTudio.Dialog')
        obj.Dlg.show;
        dlg=obj.Dlg;
    else
        dlg=DAStudio.Dialog(obj);
        obj.Dlg=dlg;
    end


