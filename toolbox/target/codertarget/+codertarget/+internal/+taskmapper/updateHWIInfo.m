function updateHWIInfo(mdlName,blkH)




    hCS=getActiveConfigSet(mdlName);
    data=get_param(hCS,'CoderTargetData');
    if~isfield(data,'TaskMap')
        data.TaskMap.EventSources='unspecified';
    end
    taskInfo=codertarget.internal.taskmapper.findHWITaskInfo(blkH);
    thisTaskName=taskInfo.TaskNames;
    thisTaskName=strrep(thisTaskName,' ','');
    refreshTaskMap=0;


    allTaskNames=codertarget.internal.taskmapper.findHWITaskNames(bdroot);
    allTaskNames=strrep(allTaskNames,' ','');

    storedTaskNames=fieldnames(data.TaskMap.Tasks);
    for i=1:numel(storedTaskNames)

        storedTask=storedTaskNames{i};
        [found,~]=ismember(storedTask,allTaskNames);
        if~found

            tempTaskId=data.TaskMap.Tasks.(storedTask);
            data.TaskMap.Tasks=rmfield(data.TaskMap.Tasks,storedTask);
            data.TaskMap.Tasks.(thisTaskName)=tempTaskId;
            refreshTaskMap=1;
        end
    end

    if refreshTaskMap
        val=data.TaskMap;
        codertarget.internal.taskmapper.setHWIInfo(hCS,val);
    end
end