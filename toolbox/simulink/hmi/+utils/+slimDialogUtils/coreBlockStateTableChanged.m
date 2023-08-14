function coreBlockStateTableChanged(dlg,obj,tag)
    [values,labels,success,msg]=utils.validateDiscreteStates(obj);
    if success
        hBlk=get(obj.getBlock(),'Handle');
        set_param(hBlk,'Values',{labels,values});
        dlg.clearWidgetWithError(tag);
        dlg.clearWidgetDirtyFlag(tag);
        utils.updateDiscreteStates(hBlk,obj.widgetId,false);
    else
        dlg.setWidgetWithError(tag,...
        DAStudio.UI.Util.Error(tag,'Error',msg,[255,0,0,100]));
    end
end