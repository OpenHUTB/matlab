function resultsInSUD=getResultsInSUD(allResults,sud)




    resultsScope=SimulinkFixedPoint.AutoscalerUtils.getResultsScopeMap(allResults,sud);
    nResults=numel(allResults);
    inSUD=true(1,nResults);
    for iResult=1:nResults
        inSUD(iResult)=resultsScope(allResults{iResult}.getUniqueIdentifier().UniqueKey);
    end
    resultsInSUD=allResults(inSUD);
end
