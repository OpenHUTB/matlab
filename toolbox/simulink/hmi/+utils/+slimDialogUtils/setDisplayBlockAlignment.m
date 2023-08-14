function setDisplayBlockAlignment(dlg,obj,paramName,paramVal)
    obj.getBlock().Alignment=paramVal;
    dlg.clearWidgetDirtyFlag(paramName);
    hBlk=get(obj.getBlock(),'handle');
    model=get_param(bdroot(hBlk),'Name');
    set_param(model,'Dirty','on');
end