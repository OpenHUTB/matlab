function arrayOfProps=undoOrderChildSignal(originalSignalChildOrder,sourceParentID,appInstanceID)




    arrayOfProps=[];


    repoManager=sta.RepositoryManager;
    scenarioID=getScenarioIDByAppID(repoManager,appInstanceID);

    repoUtil=starepository.RepositoryUtility();


    childMgr=sta.ChildManager;
    childOrderIDS=getChildOrderIDs(childMgr,sourceParentID);

    eng=sdi.Repository(true);
    eng.safeTransaction(@updateRepositoryOrder,...
    childOrderIDS,...
    originalSignalChildOrder);

    allScenario_IDS=getTopLevelIDsInTreeOrder(repoUtil,scenarioID);
    arrayOfProps=Simulink.sta.signaltree.rearrangeTreeOrder(allScenario_IDS,[],0);


    function updateRepositoryOrder(childOrderIDS,siblingIdsInOrder)

        for k=1:length(childOrderIDS)
            childOrder=sta.ChildOrder(childOrderIDS(k));
            childOrder.ChildID=siblingIdsInOrder(k);
        end
