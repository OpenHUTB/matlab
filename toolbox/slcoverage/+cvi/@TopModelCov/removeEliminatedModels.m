function updatedRefIds=removeEliminatedModels(topModelcovId)






    refModelcovIds=cv('get',topModelcovId,'.refModelcovIds');
    updatedRefIds=refModelcovIds;
    refModelcovIds(updatedRefIds==topModelcovId)=[];

    for currModelcovId=refModelcovIds(:)'
        if(cvi.TopModelCov.isModelEliminated(currModelcovId))
            modelH=cv('get',currModelcovId,'.handle');
            if is_simulink_handle(modelH)
                set_param(modelH,'CoverageId',0);
                cvi.TopModelCov.unsetModelContentsCoverageIds(modelH);
            end
            cv('ModelClose',currModelcovId);
            cv('delete',currModelcovId);
            updatedRefIds(updatedRefIds==currModelcovId)=[];
        end
    end
    cv('set',topModelcovId,'.refModelcovIds',updatedRefIds);