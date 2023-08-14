function endTimes=getTaskEndTimes(task)






    stateEnum.Running=soc.profiler.TaskState.Running;
    stateEnum.Ready=soc.profiler.TaskState.Ready;
    stateEnum.Waiting=soc.profiler.TaskState.Waiting;

    states=task.Data;

    idxWaitingStates=states==stateEnum.Waiting;
    idxWaitingStates(1)=0;
    endTimes=task.Time(idxWaitingStates)';
end