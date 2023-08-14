function setBatchModeAndUpdate(model,BatchModeValue)









    assert(ischar(model)||isstring(model)||ishandle(model),'Invalid model');

    previousBatchModeValue=get_param(model,'ExtModeBatchMode');
    set_param(model,'ExtModeBatchMode',BatchModeValue);

    simStatus=get_param(model,'SimulationStatus');
    if strcmp(BatchModeValue,'off')&&strcmp(previousBatchModeValue,'on')&&strcmp(simStatus,'external')
        set_param(model,'SimulationCommand','update');
    end
end

