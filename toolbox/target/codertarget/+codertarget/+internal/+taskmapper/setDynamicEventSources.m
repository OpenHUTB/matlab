function setDynamicEventSources(DependantSource)




    blkID=DependantSource.BlockID;
    modelName=strsplit(blkID,':');
    modelName=modelName{1};
    eventSource=strrep(DependantSource.Name,'_EventSource','');

    if isequal(DependantSource.Value,1)||isequal(DependantSource.Value,'1')
        codertarget.internal.taskmapper.addDynamicEventSources(modelName,eventSource);
    else
        codertarget.internal.taskmapper.removeDynamicEventSources(modelName,eventSource);
    end
end