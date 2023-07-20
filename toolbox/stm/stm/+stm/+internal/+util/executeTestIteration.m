function resultObj=executeTestIteration(iterationId,iterationResultId,parentTestCaseResultId,resultSetId,isLastOne,simWatcher1,simWatcher2)













    validateattributes(iterationId,"numeric",{'scalar'})

    resultSetId=stm.internal.executeATestIteration(...
    iterationId,iterationResultId,parentTestCaseResultId,resultSetId,isLastOne,simWatcher1,simWatcher2);

    resultObj=sltest.testmanager.ResultSet([],resultSetId);
end
