function out=hasUnappliedChanges(cs)






    h=cs.getDialogHandle;
    if isa(h,'DAStudio.Dialog')
        web=h.getDialogSource;
        out=web.hasUnappliedChanges;
    else
        out=false;
    end
end
