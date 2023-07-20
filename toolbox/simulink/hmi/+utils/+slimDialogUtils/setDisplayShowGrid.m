function setDisplayShowGrid(dlg,obj,paramName,paramVal)
    obj.getBlock().ShowGrid=paramVal;
    dlg.clearWidgetDirtyFlag(paramName);
    hBlk=get(obj.getBlock(),'handle');
    model=get_param(bdroot(hBlk),'Name');
    set_param(model,'Dirty','on');
end