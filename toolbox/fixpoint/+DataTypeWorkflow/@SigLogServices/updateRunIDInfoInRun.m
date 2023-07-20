function updateRunIDInfoInRun(modelName,sdiTsRunID,runName)




    rep=fxptds.FPTRepository.getInstance;
    ds=rep.getDatasetForSource(modelName);

    ds.mapSDIRunForTs(sdiTsRunID,runName);

end

