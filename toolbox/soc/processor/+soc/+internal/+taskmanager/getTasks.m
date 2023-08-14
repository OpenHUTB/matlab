function tasks=getTasks(tskMgrBlk)




    allTaskData=get_param(tskMgrBlk,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData);
    taskList=dm.getTaskNames;
    for i=1:numel(taskList)
        tasks(i)=dm.getTask(taskList{i});%#ok<AGROW>
    end
end