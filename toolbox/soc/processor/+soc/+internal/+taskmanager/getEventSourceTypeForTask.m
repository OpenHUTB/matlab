function event=getEventSourceTypeForTask(tskMgrBlk,taskName)




    tasks=soc.internal.taskmanager.getTasks(tskMgrBlk);
    idx=arrayfun(@(x)isequal(x.taskName,taskName),tasks);
    event=tasks(idx).taskEventSourceType;
end