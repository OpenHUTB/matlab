function addDynamicEventSources(modelName,newEventSource)





    hCS=getActiveConfigSet(modelName);
    data=get_param(hCS,'CoderTargetData');

    if~isfield(data,'TaskMap')||isempty(data.TaskMap.EventSources)

        data.TaskMap.EventSources='unspecified';
    end
    eventSources=strsplit(data.TaskMap.EventSources,';');
    if~any(strcmp(eventSources,newEventSource))

        data.TaskMap.EventSources=[data.TaskMap.EventSources,';',newEventSource];
        set_param(hCS,'CoderTargetData',data);
    end
end
