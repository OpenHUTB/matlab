function defaultLinePropCB_ddg(dlg,h,tag,value)




    if isa(h,'Simulink.Line')||isa(h,'Simulink.Port')
        datatype=h.getPropDataType(tag);

        if strcmp(datatype,'bool')
            if value
                value='1';
            else
                value='0';
            end
        elseif strcmp(datatype,'enum')
            entries=h.getPropAllowedValues(tag);
            value=entries{value+1};
        end

        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{tag,value});

        if~dlg.isWidgetWithError(tag)
            dlg.clearWidgetDirtyFlag(tag)
        end
    end
end


