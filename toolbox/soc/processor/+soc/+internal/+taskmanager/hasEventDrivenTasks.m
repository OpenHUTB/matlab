function ret=hasEventDrivenTasks(tskMgrBlk)




    assert(ischar(tskMgrBlk),...
    'Task manager block should be passed as string path instead of handle.');
    assert(isequal(get_param(tskMgrBlk,'MaskType'),'Task Manager'),...
    '%s should be Task Manager Block.',tskMgrBlk);

    taskData=soc.internal.TaskManagerData(get_param(tskMgrBlk,'AllTaskData'));
    evtTasks=cellfun(@(x)isequal(getTask(taskData,x).taskType,...
    'Event-driven'),getTaskNames(taskData));
    ret=any(evtTasks);
end