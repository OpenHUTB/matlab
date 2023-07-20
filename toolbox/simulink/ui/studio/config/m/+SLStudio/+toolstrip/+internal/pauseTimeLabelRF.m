


function pauseTimeLabelRF(cbinfo,action)
    modelname=cbinfo.model.Name;
    if~isempty(modelname)&&~strcmpi(get_param(modelname,'SimulationMode'),'rapid-accelerator')
        action.enabled=true;
    else
        action.enabled=false;
    end
end
