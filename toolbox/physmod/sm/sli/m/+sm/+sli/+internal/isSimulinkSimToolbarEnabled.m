function status=isSimulinkSimToolbarEnabled(model)














    if~isempty(model)&&bdIsLoaded(model)
        modelHandle=get_param(model,'Handle');
        status=SLM3I.SLDomain.isSimulationStartPauseContinueEnabled(modelHandle);
    else
        status=false;
    end

end
