function aSigName=uniqueSignalNameUnderSignal(parentID,aSigName)







    repoUtil=starepository.RepositoryUtility;

    childIDs=getChildrenIDsInSiblingOrder(repoUtil,parentID);
    signalNames=getSignalNames(repoUtil,childIDs);


    aStrUtil=sta.StringUtil();
    for k=1:length(signalNames)
        aStrUtil.addNameContext(signalNames{k});
    end

    aSigName=aStrUtil.getUniqueName(aSigName);

end
