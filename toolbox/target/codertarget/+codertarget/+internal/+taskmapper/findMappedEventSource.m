function mappedSource=findMappedEventSource(modelName,blkH)





    hCS=getActiveConfigSet(modelName);
    data=get_param(hCS,'CoderTargetData');
    mappedSource='';

    blk=get_param(get(blkH,'parent'),'Name');
    thisTaskName=strrep(blk,' ','');

    if isfield(data,'TaskMap')
        storedTaskNames=fieldnames(data.TaskMap.Tasks);
        [found,~]=ismember(thisTaskName,storedTaskNames);
        if found
            mappedSource=data.TaskMap.Tasks.(thisTaskName).MappedSource;
        end
    end
end