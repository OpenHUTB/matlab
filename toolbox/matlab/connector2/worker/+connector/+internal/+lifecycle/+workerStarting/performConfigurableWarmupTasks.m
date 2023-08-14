function performConfigurableWarmupTasks()
    e=getenv('CONNECTOR_CONFIGURABLE_WARMUP_TASKS');

    if~isempty(e)
        taskIds=strsplit(e,'+');
        cellfun(@(s)doTask(strtrim(s)),taskIds)
    end
end

function doTask(taskId)
    logger=connector.internal.Logger('connector::worker_m');
    try
        logger.info(['Performing warmup task: ',taskId]);
        eval(['connector.internal.warmupTasks.',taskId]);
    catch MExc
        logger.warning(MExc.getReport);
    end
end
