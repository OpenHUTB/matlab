function initEnableInFalseRoutine(pouBlock)




    if~strcmp(get_param(bdroot(pouBlock),'SimulationStatus'),'stopped')
        return;
    end

    routineBlockPath=slplc.utils.getInternalBlockPath(pouBlock,'EnableInFalse');
    enableInTrueOnlyBlock=[pouBlock,'/EnableInTrueOnly'];
    enableInFalseBlock=[pouBlock,'/EnableInFalse'];

    if strcmpi(get_param(pouBlock,'PLCAllowEnableInFalse'),'off')
        set_param(routineBlockPath,'Commented','on');
        set_param(enableInTrueOnlyBlock,'Commented','off');
        set_param(enableInFalseBlock,'Commented','on');
    else
        set_param(routineBlockPath,'Commented','off');
        set_param(enableInTrueOnlyBlock,'Commented','on');
        set_param(enableInFalseBlock,'Commented','off');
    end
end
