function out=getSyncRatesDependencies(topMdl)




    import soc.internal.connectivity.*




    tskMgrBlk=getTaskManagerBlock(topMdl);
    allTaskData=get_param(tskMgrBlk,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData,'evaluate',topMdl);
    taskList=dm.getTaskNames;
    taskPeriods=zeros(1,numel(taskList));
    for i=1:numel(taskList)
        task=dm.getTask(taskList{i});
        if isequal(task.taskType,'Timer-driven')
            taskPeriods(i)=task.taskPeriod;
        end
    end
    depMap=getTaskOnFasterTaskDependencyMap(topMdl,tskMgrBlk);
    out=constructSyncDependencyData(depMap);

    sBaseRate=get_param(bdroot,'CompiledStepSize');
    if~isequal(str2double(sBaseRate),min(taskPeriods))
        out.RateDependencies=out.RateDependencies+1;
        out.RateDependStart=[0,out.RateDependStart];
        out.RateDependLength=[0,out.RateDependLength];
    end

end


function info=constructSyncDependencyData(rateDependencyMap)
    info=[];
    info.RateDependencies=[];
    for i=1:numel(rateDependencyMap)
        rateDep=rateDependencyMap{i};
        info.RateDependStart(i)=numel(info.RateDependencies)+1;
        info.RateDependLength(i)=0;
        for j=1:numel(rateDep)
            info.RateDependencies=[info.RateDependencies,rateDep(j)];
            info.RateDependLength(i)=info.RateDependLength(i)+1;
        end
    end

    info.RateDependencies=info.RateDependencies-1;
    info.RateDependStart=info.RateDependStart-1;
end









