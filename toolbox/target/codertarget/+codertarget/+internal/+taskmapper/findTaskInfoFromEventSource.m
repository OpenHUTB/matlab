function taskInfo=findTaskInfoFromEventSource(modelName,mappedSource)





    hCS=getActiveConfigSet(modelName);
    data=get_param(hCS,'CoderTargetData');
    taskInfo=struct;
    taskInfo.TaskName='';
    taskInfo.TaskPriority='';

    if isfield(data,'TaskMap')
        allTaskNames=fieldnames(data.TaskMap.Tasks)';
        for i=1:numel(allTaskNames)

            thisTaskName=allTaskNames{i};
            if ismember(mappedSource,data.TaskMap.Tasks.(thisTaskName).MappedSource)
                taskInfo.TaskName=thisTaskName;
                taskInfo.TaskPriority=data.TaskMap.Tasks.(thisTaskName).TaskPriority;
            end
        end
    end
end