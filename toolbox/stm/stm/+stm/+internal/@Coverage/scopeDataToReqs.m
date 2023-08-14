


function hasReqs=scopeDataToReqs(rs,shouldScope)
    rs=stm.internal.Coverage.getResultSetObj(rs);
    [covObjects,topModels,crID,isValidCvResults]=rs.getCoverageResults;
    for i=1:length(isValidCvResults)
        if isValidCvResults(i)==false
            error(stm.internal.Coverage.getCovErrorMsg(topModels{i},'ScopeWithIncompatibleCvdataError'));
        end
    end

    [covObjects.scopeDataToReqs]=deal(shouldScope);


    arrayfun(@stm.internal.Coverage.getNewCovMetricsAndUpdateDB,crID,covObjects);
    stm.internal.updateCoverageResults(rs.getID,int32(shouldScope),'UpdateScope');
    stm.internal.updateCoverageResults([],crID(1),'UpdateUI');




    hasReqs=(~isempty(rs.getReqMdlTestInfo.ImplementLink))||(~shouldScope);
end
