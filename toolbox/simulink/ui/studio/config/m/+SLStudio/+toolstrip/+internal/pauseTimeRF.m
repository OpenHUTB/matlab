


function pauseTimeRF(cbinfo,action)
    modelname=cbinfo.model.Name;
    if~isempty(modelname)&&strcmpi(get_param(modelname,'SimulationMode'),'rapid-accelerator')
        action.text='';
        action.enabled=false;
    elseif~isempty(modelname)&&strcmpi(get_param(modelname,'EnablePauseTimes'),'on')
        action.text=get_param(modelname,'PauseTimes');
    else
        action.text='';
    end
end

