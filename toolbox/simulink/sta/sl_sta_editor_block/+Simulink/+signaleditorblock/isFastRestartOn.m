function bool=isFastRestartOn(blockPath)





    bool=(strcmp(get_param(bdroot(blockPath),'SimulationStatus'),'compiled')||...
    strcmp(get_param(bdroot(blockPath),'SimulationStatus'),'restarting'))&&...
    strcmp(get_param(bdroot(blockPath),'FastRestart'),'on');
end

