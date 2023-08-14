function defaultPortPropCB_ddg(dlg,h,tag,value)




    if isa(h,'Simulink.Port')

        newTag=tag;
        if startsWith(tag,'port_')
            newTag=erase(tag,'port_');
        end

        datatype=h.getPropDataType(newTag);

        if strcmp(datatype,'bool')
            if value
                value='1';
            else
                value='0';
            end
        elseif strcmp(datatype,'enum')
            entries=h.getPropAllowedValues(newTag);
            value=entries{value+1};
        end

        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{tag,value});

        if~dlg.isWidgetWithError(tag)
            dlg.clearWidgetDirtyFlag(tag)
        end
    end
end


