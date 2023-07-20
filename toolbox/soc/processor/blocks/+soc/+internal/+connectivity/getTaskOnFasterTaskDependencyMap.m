function dependencyMap=getTaskOnFasterTaskDependencyMap(topMdl,tskMgr)








    import soc.internal.connectivity.*

    allTaskData=get_param(tskMgr,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData,'evaluate',topMdl);
    taskList=dm.getTaskNames;
    dependencyMap=cell(1,numel(taskList));

    mdl=getModelConnectedToTaskManager(tskMgr);
    name=get_param(mdl,'ModelName');
    dep=getRateDependenciesInRateAdapterModel(name);
    taskPeriods=zeros(1,numel(taskList));
    for i=1:numel(taskList)
        task=dm.getTask(taskList{i});
        if isequal(task.taskType,'Timer-driven')
            taskPeriods(i)=task.taskPeriod;
        end
    end
    taskPeriods=sort(taskPeriods);
    mkeys=dep.keys;
    for i=1:numel(mkeys)
        thisPeriod=mkeys{i};
        depTskPeriods=dep(thisPeriod);
        for j=1:numel(depTskPeriods)
            if(depTskPeriods(j)<thisPeriod)
                [~,idx]=ismember(depTskPeriods(j),taskPeriods);
                [~,idx1]=ismember(thisPeriod,taskPeriods);
                dependencyMap{idx1}=[dependencyMap{idx1},idx];
            end
        end
    end
end