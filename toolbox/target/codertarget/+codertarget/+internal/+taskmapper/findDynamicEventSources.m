function intSources=findDynamicEventSources(modelName)





    intSources={'unspecified'};

    hCS=getActiveConfigSet(modelName);


    data=get_param(hCS,'CoderTargetData');
    if isfield(data,'TaskMap')



        eventSources=split(data.TaskMap.EventSources,';');
        [found,~]=ismember('unspecified',eventSources);
        if found
            intSources=eventSources;
        else

            intSources=[intSources,eventSources];
        end
    end
end