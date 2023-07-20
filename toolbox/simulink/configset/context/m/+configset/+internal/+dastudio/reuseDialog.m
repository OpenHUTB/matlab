function out=reuseDialog(dlg,cs)






    out=false;
    if isa(dlg,'DAStudio.Dialog')
        csme=dlg.getSource;
        if csme.node==cs
            dlg.show;
            out=true;
        else
            dlg.delete;
        end
    end
