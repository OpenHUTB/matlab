function onModelStart(modelHandle)



    simTarget=get_param(modelHandle,'ModelReferenceTargetType');

    Simulink.HMI.handleModelStart(modelHandle,...
    get_param(modelHandle,'SimulationMode'),...
    ~strcmpi(simTarget,'none'));

end

