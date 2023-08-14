function taskDurations=getTaskDurations(task)






    stateEnum.Running=soc.profiler.TaskState.Running;
    stateEnum.Ready=soc.profiler.TaskState.Ready;
    stateEnum.Waiting=soc.profiler.TaskState.Waiting;

    idxRunningStates=find(task.Data==stateEnum.Running);
    taskDurations=[];
    if~isempty(idxRunningStates)
        endIdx=idxRunningStates(1)-1;
        for ii=1:length(idxRunningStates)
            thisDuration=0;
            startIdx=endIdx+1;
            if(startIdx>=length(task.Data))
                break;
            end

            endIdx=startIdx;
            while(task.Data(endIdx)~=stateEnum.Waiting)&&(endIdx<length(task.Data))
                endIdx=endIdx+1;
                if(task.Data(endIdx)==stateEnum.Ready)&&...
                    task.Data(endIdx-1)==stateEnum.Running
                    thisDuration=thisDuration+task.Time(endIdx)-task.Time(endIdx-1);
                end
            end
            thisDuration=thisDuration+task.Time(endIdx)-task.Time(endIdx-1);
            if~isequal(thisDuration,0)
                taskDurations=[taskDurations;thisDuration];%#ok<*AGROW>
            end
        end
        taskDurations=taskDurations';
    end
end
