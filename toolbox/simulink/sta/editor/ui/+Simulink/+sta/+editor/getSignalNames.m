function signalNames=getSignalNames(topLevelSignalIDs)







    repoUtil=starepository.RepositoryUtility();

    N_IDS=length(topLevelSignalIDs);
    signalNames=cell(1,N_IDS);
    for k=1:N_IDS
        signalNames{k}=repoUtil.getSignalLabel(topLevelSignalIDs(k));
    end
end