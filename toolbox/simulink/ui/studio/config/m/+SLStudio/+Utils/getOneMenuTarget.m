function obj=getOneMenuTarget(cbinfo)




    if cbinfo.isContextMenu
        obj=cbinfo.target;
    else
        obj=SLStudio.Utils.getSingleSelection(cbinfo);
    end
end
