function setDisplayBlockFormat(dlg,obj,paramName,paramVal)


    paramVal=paramVal+3;
    obj.getBlock().Format=paramVal;
    dlg.clearWidgetDirtyFlag(paramName);
    hBlk=get(obj.getBlock(),'handle');
    model=get_param(bdroot(hBlk),'Name');
    set_param(model,'Dirty','on');

    dlg.setEnabled('formatString',strcmp(obj.getBlock().Format,DAStudio.message('SimulinkHMI:dashboardblocks:CUSTOM')));
end