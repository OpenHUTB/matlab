function startTimes=getTaskStartTimes(task)





    stateEnum.Running=soc.profiler.TaskState.Running;
    stateEnum.Ready=soc.profiler.TaskState.Ready;
    stateEnum.Waiting=soc.profiler.TaskState.Waiting;



    isKernelProfiler=~isempty(task.Data)&&(length(task.Data)>2)&&...
    task.Data(1)==soc.profiler.TaskState.Waiting&&...
    task.Data(2)==soc.profiler.TaskState.Ready;

    idxRunningStates=find(task.Data==stateEnum.Running);


    states=task.Data;
    if isKernelProfiler


        for i=numel(idxRunningStates):-1:1
            idx=idxRunningStates(i);
            if(states(idx-1)==stateEnum.Ready)&&...
                (states(idx-2)==stateEnum.Running)
                idxRunningStates(i)=[];
            end
        end
    else
        for i=numel(idxRunningStates):-1:1
            idx=idxRunningStates(i);
            if(states(idx-1)==stateEnum.Ready)
                idxRunningStates(i)=[];
            end
        end
    end

    startTimes=task.Time(idxRunningStates)';
end
