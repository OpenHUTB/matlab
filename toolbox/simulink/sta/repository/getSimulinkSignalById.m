function[simulinkSignal]=getSimulinkSignalById(dbId)




    try
        repoUtil=starepository.RepositoryUtility();
        simulinkSignal=getSimulinkSignalByID(repoUtil,dbId);
    catch ME
        rethrow(ME);
    end

end

