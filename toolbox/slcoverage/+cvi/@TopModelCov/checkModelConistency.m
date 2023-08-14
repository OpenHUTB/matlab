function checkModelConistency(modelCvId)




    try
        if~SlCov.ContextGuard.isModelUnchanged(SlCov.CoverageAPI.getModelcovName(modelCvId))
            logStr=cv('CheckConsistency',modelCvId);



            if~isempty(logStr)&&~SlCov.CoverageAPI.isGeneratedCode(modelCvId)
                disp(logStr)
            end
        end
    catch MEx
        rethrow(MEx);
    end
