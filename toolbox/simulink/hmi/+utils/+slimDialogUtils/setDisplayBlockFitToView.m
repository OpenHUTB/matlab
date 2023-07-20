function setDisplayBlockFitToView(dlg,obj,paramName,paramVal)
    obj.getBlock().Layout=paramVal;
    dlg.clearWidgetDirtyFlag(paramName);
    hBlk=get(obj.getBlock(),'handle');
    model=get_param(bdroot(hBlk),'Name');
    set_param(model,'Dirty','on');
end