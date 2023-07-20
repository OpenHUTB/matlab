function[preparedNnetModel,report]=prepare(networkToPrep,trainingInput,trainingTarget)















    modelPrep=DataTypeWorkflow.Advisor.ModelPreparator(networkToPrep,trainingInput,trainingTarget);
    preparedNnetModel=modelPrep.ModelForFxpConversion;
    report=modelPrep.Report;
end