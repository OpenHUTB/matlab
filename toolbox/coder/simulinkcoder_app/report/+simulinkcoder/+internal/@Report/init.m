function init(obj)




    obj.subscribe=message.subscribe(obj.channel,@(msg)obj.actionDispatcher(msg));


    obj.features.annotation=false;
    obj.features.coverage=true;
    obj.features.profiling=true;
    obj.features.tooltip=true;
    obj.features.coverageTooltip=true;
    obj.features.showJustificationLinks=false;
    obj.features.coverageTooltip=false;
    obj.features.showProfilingInfo=false;
    obj.features.showTaskSummary=false;
