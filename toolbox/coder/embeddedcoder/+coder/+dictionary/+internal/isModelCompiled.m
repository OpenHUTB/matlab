function isCompiled=isModelCompiled(model)




    simStatus=get_param(model,'SimulationStatus');
    isCompiled=strcmpi(simStatus,'paused')||...
    strcmpi(simStatus,'initializing')||...
    strcmpi(simStatus,'running')||...
    strcmpi(simStatus,'updating');
end
