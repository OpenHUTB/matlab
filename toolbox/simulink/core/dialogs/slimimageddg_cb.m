function slimimageddg_cb(dlg,h,tag,value)

    prop=tag;
    pVal=value;
    doSendUpdateEvent=true;

    switch tag
    case 'DropShadow'
        if value
            pVal='on';
        else
            pVal='off';
        end
    case 'ClickFcn'
        h.ClickFcn=value;
        doSendUpdateEvent=false;
    end

    if doSendUpdateEvent
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{prop,pVal});
    end

    if~dlg.isWidgetWithError(tag)
        dlg.clearWidgetDirtyFlag(tag)
    end
end