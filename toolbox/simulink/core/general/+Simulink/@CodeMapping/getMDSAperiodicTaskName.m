function taskName=getMDSAperiodicTaskName(model,blockH)





    taskName=[];

    mm=get_param(model,'MappingManager');
    acm=mm.getActiveMappingFor('DistributedTarget');
    mappedTask=acm.getMappedTasks(blockH);

    if~isempty(mappedTask)

        assert(numel(mappedTask)==1,...
        'Should only be mapped to one aperiodic task');
        taskName=mappedTask.EntryPointName;
    end
end
