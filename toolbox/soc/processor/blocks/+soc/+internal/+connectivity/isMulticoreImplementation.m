function res=isMulticoreImplementation(topMdl,tskMgr)





    import soc.internal.connectivity.*

    allTaskData=get_param(tskMgr,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData,'evaluate',topMdl);
    taskList=dm.getTaskNames;
    usedCores=[];
    for i=1:numel(taskList)
        task=dm.getTask(taskList{i});
        usedCores(end+1)=task.coreNum;%#ok<AGROW>
    end
    res=numel(unique(usedCores))>1;
end