function registerTask(blockHandle)




    blk=blockHandle;
    mdl=bdroot(blk);

    name=get_param(blk,'taskName');
    type=get_param(blk,'taskType');
    period=get_param(blk,'taskPeriod');
    priority=get_param(blk,'taskPriority');
    core=get_param(blk,'coreNum');

    durationSource=get_param(blk,'taskDurationSource');
    duration=get_param(blk,'taskDuration');
    deviation=get_param(blk,'taskDurationDeviation');

    isPlayback=get_param(blk,'PlaybackRecorded');
    isDropOverran=isequal(get_param(blk,'dropOverranTasks'),'on');
    isLogExecution=isequal(get_param(blk,'logExecutionData'),'on');
    isLogDropped=isequal(get_param(blk,'logDroppedTasks'),'on');

    if isequal(type,'Event-driven')
        eventID=get_param(blk,'taskEvent');
    else
        eventID='clock';
    end

    period=soc.blocks.evaluateBlockParameter(period,mdl);
    core=soc.blocks.evaluateBlockParameter(core,mdl);
    priority=soc.blocks.evaluateBlockParameter(priority,mdl);


    env=codertarget.targethardware.getEnvironment(mdl);
    if~isempty(env)
        soc.internal.taskmanager.validateTaskParameters(name,...
        type,period,core,priority,...
        (0:env.NumCores-1),env.TaskPriorities);


        soc.internal.ESBRegistry.addTask(blockHandle,...
        name,eventID,period,priority,core,...
        isDropOverran,isPlayback,durationSource,...
        duration,deviation,isLogExecution,...
        isLogDropped);
    end
end
