function obj=getModelCloseUtil(~)
    if is_simulink_loaded()
        obj=Simulink.SimulationData.ModelCloseUtil();
    else
        obj=[];
    end
end
