function open(obj)


    if isa(obj.ui,'DAStudio.Dialog')
        obj.ui.show;
    else
        obj.ui=DAStudio.Dialog(obj);
    end

