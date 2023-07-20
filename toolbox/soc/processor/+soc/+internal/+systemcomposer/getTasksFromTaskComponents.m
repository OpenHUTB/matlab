function tasks=getTasksFromTaskComponents(components)




    periodicTaskSt='soc_blockset_profile.PeriodicSoftwareTask';
    aperiodicTaskSt='soc_blockset_profile.AperiodicSoftwareTask';
    tasks=arrayfun(@(x)locInitializeTaskStructure,1:numel(components));
    for i=1:numel(components)
        tasks(i).taskName=components(i).Name;
        stereotypes=components(i).getStereotypes;
        if any(ismember(stereotypes,periodicTaskSt))
            stereotype=periodicTaskSt;
            period=iGetPropVal(components(i),stereotype,'Period');
            tasks(i).taskType='Timer-driven';
            tasks(i).taskPeriod=period;
        else
            stereotype=aperiodicTaskSt;
            priority=iGetPropVal(components(i),stereotype,'Priority');
            tasks(i).taskType='Event-driven';
            tasks(i).taskPriority=priority;
            tasks(i).taskEvent=[tasks(i).taskName,'Event'];
        end
        tasks(i).coreNum=iGetPropVal(components(i),stereotype,'CoreAffinity');
        tasks(i)=iSetTaskDuration(tasks(i),components(i),stereotype);
    end
    function t=iSetTaskDuration(t,c,st)
        t.taskDurationData.mean=iGetPropVal(c,st,'MeanExecutionTime');
        t.taskDurationData.min=iGetPropVal(c,st,'MinExecutionTime');
        t.taskDurationData.max=iGetPropVal(c,st,'MaxExecutionTime');
        t.taskDurationData.dev=iGetPropVal(c,st,'ExecutionTimeStd');
    end
    function value=iGetPropVal(component,stereotype,property)
        str=[stereotype,'.',property];
        value=component.getPropertyValue(str);
    end
end


function taskStr=locInitializeTaskStructure
    taskStr=struct('taskName','',...
    'taskType','Event-driven',...
    'taskEvent','<empty>',...
    'taskPeriod','1',...
    'taskPriority','10',...
    'coreNum','0',...
    'dropOverranTasks',false,...
    'taskDurationSource','Dialog',...
    'diagnosticsFile','',...
    'logExecutionData',true,...
    'logDroppedTasks',false,...
    'playbackRecorded',false,...
    'taskDurationData',locGetDefaultTaskDurationData);
end


function dur=locGetDefaultTaskDurationData
    dur=struct('percent','100',...
    'mean','1.0000e-06',...
    'dev','0',...
    'min','1.0000e-06',...
    'max','1.0000e-06');
end
