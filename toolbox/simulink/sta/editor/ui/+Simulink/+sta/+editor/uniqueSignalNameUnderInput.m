function aSigName=uniqueSignalNameUnderInput(scenarioID,aSigName)






    theScenarioRepoItem=sta.Scenario(scenarioID);
    topLevelSignalIDs=getSignalIDs(theScenarioRepoItem);
    repo=starepository.RepositoryUtility();
    signalNames=getSignalNames(repo,topLevelSignalIDs);


    aStrUtil=sta.StringUtil();
    for k=1:length(signalNames)
        aStrUtil.addNameContext(signalNames{k});
    end

    aSigName=aStrUtil.getUniqueName(aSigName);

end