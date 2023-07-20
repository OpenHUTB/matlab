function taskNames=getEventDrivenTasks(modelName)








    import soc.internal.connectivity.*

    taskMgrBlk=getTaskManagerBlock(modelName);
    allTaskData=get_param(taskMgrBlk,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData);
    allTasks=dm.getTask(dm.getTaskNames);
    allTskIdx=arrayfun(@(x)contains(x.taskType,...
    'Event-driven'),allTasks);
    if isempty(allTskIdx)
        taskNames={};
    else
        allTasks=allTasks(allTskIdx);
        allTaskNames={allTasks.taskName};
        taskNames={};
        for i=1:numel(allTaskNames)
            if isTestbenchTask(modelName,allTaskNames{i}),continue;end
            taskNames{end+1}=allTaskNames{i};%#ok<AGROW>
        end
    end
end
