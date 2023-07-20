function modelCovIds=getModelCovIdsForReporting(this)





    modelCovIds=this.getAllModelcovIds;
    if this.forceTopModelResultsRemoval
        topModelCvId=get_param(this.topModelH,'CoverageId');
        modelCovIds(modelCovIds==topModelCvId)=[];
    end
end