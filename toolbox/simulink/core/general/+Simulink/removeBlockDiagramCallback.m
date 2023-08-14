function removeBlockDiagramCallback(bd,type,id)











    obj=get_param(bd,'Object');
    obj.removeCallback(type,id);

end
