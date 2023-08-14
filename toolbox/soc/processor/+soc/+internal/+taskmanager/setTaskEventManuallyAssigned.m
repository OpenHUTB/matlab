function setTaskEventManuallyAssigned(blk)




    import soc.internal.taskmanager.*

    assignStr=DAStudio.message('codertarget:utils:ManuallyAssigned');
    rawData=get_param(blk,'AllTaskData');
    dm=soc.internal.TaskManagerData(rawData);
    taskNames=getEventDrivenTaskNames(blk);
    for i=1:numel(taskNames)
        dm.updateTask(taskNames{i},'taskEventSourceAssignmentType',assignStr);
    end
    newData=dm.getData;
    set_param(blk,'AllTaskData',newData);
end