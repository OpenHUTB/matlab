function event=getEventSourceForTask(tskMgrBlk,taskName)




    tasks=soc.internal.taskmanager.getTasks(tskMgrBlk);
    idx=arrayfun(@(x)isequal(x.taskName,taskName),tasks);
    event=tasks(idx).taskEventSource;
end