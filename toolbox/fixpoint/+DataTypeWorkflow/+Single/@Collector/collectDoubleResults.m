function err=collectDoubleResults(this)










    collectInfoToDataset(this);


    fptRepositoryInstance=fxptds.FPTRepository.getInstance;


    modelObject=get_param(this.SelectedSystem,'Object');


    modelName=SimulinkFixedPoint.AutoscalerUtils.getModelForAutoscaling(modelObject);


    modelDataSet=fptRepositoryInstance.getDatasetForSource(modelName);


    runObj=modelDataSet.getRun('D2S_Run_Collector_Internal_Run_Name');




    groups=runObj.dataTypeGroupInterface.getGroups();


    resultsUnderSUD=this.performProposal(groups);


    this.compiledDoubleResultsCache=resultsUnderSUD;

    err='';
end


