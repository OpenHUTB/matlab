function[status,id]=revertFilter(obj,dlg)




    try
        status=true;
        id='';
        obj.filterEditor.revert(dlg);
    catch MEx
        display(MEx.stack(1));
    end
end