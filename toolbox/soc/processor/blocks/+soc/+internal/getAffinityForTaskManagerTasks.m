function taskAffinity=getAffinityForTaskManagerTasks(modelName,taskName)




    taskAffinity=uint32(0);

    taskManagerBlk=codertarget.utils.findTaskManager(modelName);

    if~isempty(taskManagerBlk)
        allTaskData=get_param(taskManagerBlk{1},'AllTaskData');
        dm=soc.internal.TaskManagerData(allTaskData,'evaluate',modelName);
        allTasks=dm.getTask(dm.getTaskNames);
        tmrTskIdx=arrayfun(@(x)contains(x.taskType,'Timer-driven'),allTasks);
        taskMgrTimerTasks=allTasks(tmrTskIdx);
        for i=1:numel(taskMgrTimerTasks)
            found=isequal(taskMgrTimerTasks(i).taskName,taskName);
            if found
                taskAffinity=uint32(taskMgrTimerTasks(i).coreNum);
            end
        end
    end

end

