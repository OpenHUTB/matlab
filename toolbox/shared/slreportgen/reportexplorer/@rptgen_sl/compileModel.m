function compileModel(model)




    if isempty(model)
        return;
    end

    modelH=slreportgen.utils.getModelHandle(model);
    modelName=get_param(modelH,'Name');

    try
        status=get_param(modelH,'SimulationStatus');
        switch status
        case 'stopped'
            slreportgen.utils.compileModel(modelH);
        case 'paused'

        otherwise

            rptgen.displayMessage(...
            sprintf(getString(message('RptgenSL:rptgen_sl:cannotCompileInStateMsg')),modelName,status),...
            2);
        end
    catch ex
        rptgen.displayMessage(...
        sprintf(getString(message('RptgenSL:rptgen_sl:cannotCompileMsg')),modelName,ex.message),...
        5);
        rethrow(ex);
    end
