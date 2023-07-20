function removeDynamicEventSources(modelName,removeEventSource)





    hCS=getActiveConfigSet(modelName);
    data=get_param(hCS,'CoderTargetData');

    if isfield(data,'TaskMap')&&~isempty(data.TaskMap.EventSources)
        eventSources=strsplit(data.TaskMap.EventSources,';');
        if any(strcmp(eventSources,removeEventSource))

            data.TaskMap.EventSources=strrep(data.TaskMap.EventSources,[';',removeEventSource],'');
            set_param(hCS,'CoderTargetData',data);
        end
    end

end
