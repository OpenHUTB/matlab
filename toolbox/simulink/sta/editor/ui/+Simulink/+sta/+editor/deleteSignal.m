function idsToRemove=deleteSignal(sigID,appInstanceID,baseMsg)




    idsToRemove=[];

    if nargin>1
        appInstanceID=convertStringsToChars(appInstanceID);
    end

    if nargin>2
        baseMsg=convertStringsToChars(baseMsg);
    end

    eng=sdi.Repository(true);
    repoUtil=starepository.RepositoryUtility();

    for kID=1:length(sigID)



        parentID=eng.getSignalParent(sigID(kID));




        if parentID~=0


            oldestParent=repoUtil.getOldestRelative(sigID(kID));


            removeParent(repoUtil,sigID(kID));


            repoUtil.setMetaDataByName(sigID(kID),'IS_EDITED',1);


            if oldestParent~=0
                repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
            end
        else
            repoManager=sta.RepositoryManager();
            scenarioid=getScenarioIDByAppID(repoManager,appInstanceID);
            removeExternalSourceFromScenario(repoManager,scenarioid,sigID(kID));
            repoUtil.setMetaDataByName(sigID(kID),'IS_EDITED',1);
        end


        childIDs=getChildrenIDsInSiblingOrder(repoUtil,sigID(kID));

        idsToRemove=[idsToRemove,sigID(kID),childIDs];
    end












