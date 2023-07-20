function taskInfo=findHWITaskInfo(blk)



    taskInfo=struct;
    mdlName=bdroot(blk);
    [found,~]=ismember(blk,codertarget.internal.taskmapper.findHWI(mdlName));
    if found
        taskInfo.TaskNames=get_param(blk,'Name');
        taskInfo.TaskPriorites=get_param(blk,'TaskPriority');
        taskInfo.DisablePreemption=get_param(blk,'DisablePreemption');
    end
end