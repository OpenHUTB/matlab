function removeHWIInfo(mdlName,blkH)



    hCS=getActiveConfigSet(mdlName);
    data=get_param(hCS,'CoderTargetData');
    if~isfield(data,'TaskMap')
        data.TaskMap.EventSources='unspecified';
    end
    taskInfo=codertarget.internal.taskmapper.findHWITaskInfo(blkH);
    thisTaskName=taskInfo.TaskNames;
    thisTaskName=strrep(thisTaskName,' ','');


    if isfield(data.TaskMap,'Tasks')
        storedTaskNames=fieldnames(data.TaskMap.Tasks);
        [found,~]=ismember(thisTaskName,storedTaskNames);
    else

        found=0;
    end
    refreshTaskMap=0;
    if found

        data.TaskMap.Tasks=rmfield(data.TaskMap.Tasks,thisTaskName);
        refreshTaskMap=1;
    end
    if refreshTaskMap
        val=data.TaskMap;
        codertarget.internal.taskmapper.setHWIInfo(hCS,val);
    end
end