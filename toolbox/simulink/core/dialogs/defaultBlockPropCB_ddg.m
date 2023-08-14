function defaultBlockPropCB_ddg(dlg,h,tag,value)



    if isa(h,'Simulink.Block')
        prop=tag;
        if strcmp(tag,'callbackEdit')
            obj=dlg.getSource;
            prop=obj.ParameterStruct.cbk.temp{obj.CallbackFcnIndex};
        end
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{prop,value});

        if~strcmp(prop,tag)||~dlg.isWidgetWithError(tag)
            dlg.clearWidgetDirtyFlag(tag)
        end
    end
end


