


function setToFileName(dlg,obj,tag,value)
    blockHandle=get(obj.blockObj,'handle');

    value=utils.recordDialogUtils.formatFileName(blockHandle,value);
    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{tag,value});
    utils.recordDialogUtils.updateFileHistory(blockHandle,value);

    if~dlg.isWidgetWithError(tag)
        dlg.clearWidgetDirtyFlag(tag);
    end
end

