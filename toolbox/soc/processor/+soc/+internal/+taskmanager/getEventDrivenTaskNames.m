function taskList=getEventDrivenTaskNames(inArg)




    if~isa(inArg,'soc.internal.TaskManagerData')

        allTaskData=get_param(inArg,'AllTaskData');
        dmObj=soc.internal.TaskManagerData(allTaskData);
    else
        dmObj=inArg;
    end
    taskNames=dmObj.getTaskNames;
    allTasks=dmObj.getTask(taskNames);
    idx=arrayfun(@(x)isequal(x.taskType,'Event-driven'),allTasks);
    taskList=taskNames(idx);
end
