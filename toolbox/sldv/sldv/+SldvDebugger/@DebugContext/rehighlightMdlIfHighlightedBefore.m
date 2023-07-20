

function rehighlightMdlIfHighlightedBefore(obj)



    avtH=get_param(obj.debugMdl,'AutoVerifyData');
    if~isempty(avtH)&&isfield(avtH,'modelView')&&avtH.DebugService.isSldvAnalysisHighlightActive
        dataFile=avtH.currentResult.DataFile;
        if isempty(dataFile)
            sldvloadresults(obj.debugMdl);
            dataFile=sldvprivate('mdl_current_results',obj.debugMdl).DataFile;
        end
        modelName=get_param(obj.debugMdl,'Name');
        sldvprivate('urlcall','highlight',dataFile,modelName);
    end
end
