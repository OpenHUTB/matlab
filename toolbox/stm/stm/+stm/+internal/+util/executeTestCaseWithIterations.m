function resultObj=executeTestCaseWithIterations(tcId,iterationIdList)










    itrIdList=[];
    if(nargin>=2)
        itrIdList=iterationIdList;
    end
    if(isempty(itrIdList))
        resultSetId=stm.internal.executeATestCaseWithSelectedIterations(tcId);
    else
        resultSetId=stm.internal.executeATestCaseWithSelectedIterations(tcId,itrIdList);
    end

    resultObj=sltest.testmanager.ResultSet([],resultSetId);
end
