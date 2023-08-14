function defaultModelPropCB_ddg(dlg,h,tag,value)



    if isa(h,'Simulink.BlockDiagram')
        prop=tag;
        if strcmp(prop,'UpdateHistory')||...
            strcmp(prop,'EnableAccessToBaseWorkspace')
            value=num2str(value);
        end

        if strcmp(prop,'callbackEdit')
            obj=dlg.getSource;
            prop=obj.Callbacks{obj.CallbackFcnIndex};
        end
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{prop,value});

        if~strcmp(prop,tag)||~dlg.isWidgetWithError(tag)
            dlg.clearWidgetDirtyFlag(tag)
        end
    end
end


