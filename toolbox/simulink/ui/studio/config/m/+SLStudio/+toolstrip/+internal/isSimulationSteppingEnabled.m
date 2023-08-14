function res=isSimulationSteppingEnabled(cbinfo)
    modelHandle=cbinfo.model.handle;
    sim_mode=get_param(modelHandle,'SimulationMode');

    switch sim_mode
    case{'normal','accelerator'}
        res=cbinfo.domain.isSimulationStartPauseContinueEnabled(modelHandle);
    otherwise
        res=false;
    end
end