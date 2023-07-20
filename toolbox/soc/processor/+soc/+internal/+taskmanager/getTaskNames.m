function taskList=getTaskNames(tskMgrBlk)




    allTaskData=get_param(tskMgrBlk,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData);
    taskList=dm.getTaskNames;
end