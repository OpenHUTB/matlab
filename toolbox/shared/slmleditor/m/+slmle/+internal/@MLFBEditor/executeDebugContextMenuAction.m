function executeDebugContextMenuAction(obj,actionId)



    objectId=obj.objectId;
    chartId=sf('get',objectId,'state.chart');
    machineId=sf('get',chartId,'.machine');


    switch actionId
    case 'stepOver'
        sfprivate('eml_man','debugger_step',machineId);
    case 'stepIn'
        sfprivate('eml_man','debugger_step_in',machineId);
    case 'stepOut'
        sfprivate('eml_man','debugger_step_out',machineId);
    case 'continue'
        sfprivate('eml_man','debugger_continue',machineId);
    case 'stop'
        sfprivate('eml_man','debugger_stop');
    end


