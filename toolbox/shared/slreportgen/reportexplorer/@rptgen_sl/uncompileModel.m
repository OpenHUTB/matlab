function uncompileModel(model)




    if isempty(model)
        return;
    end

    modelH=slreportgen.utils.getModelHandle(model);
    modelName=get_param(modelH,'Name');

    try
        status=get_param(modelH,'SimulationStatus');
        switch status
        case 'paused'
            slreportgen.utils.uncompileModel(modelH);
        case 'stopped'

        otherwise

            rptgen.displayMessage(...
            sprintf(getString(message('RptgenSL:rptgen_sl:cannotTerminateInStateMsg')),modelName,status),...
            2);
        end
    catch ex
        rptgen.displayMessage(...
        sprintf(getString(message('RptgenSL:rptgen_sl:cannotTerminateMsg')),modelName,ex.message),...
        5);
    end



