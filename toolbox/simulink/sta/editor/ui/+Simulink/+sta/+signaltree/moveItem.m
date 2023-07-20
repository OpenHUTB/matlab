function arrayOfProps=moveItem(sigIdToMove,MOVE_UP,baseMsg,appInstanceID,varargin)



    RE_ORDER_TREE=true;
    if~isempty(varargin)
        RE_ORDER_TREE=varargin{1};
    end

    repoUtil=starepository.RepositoryUtility();

    sourceParentID=getParent(repoUtil,sigIdToMove);


    repoManager=sta.RepositoryManager;
    scenarioID=getScenarioIDByAppID(repoManager,appInstanceID);

    allScenario_IDS=getTopLevelIDsInTreeOrder(repoUtil,scenarioID);

    if sourceParentID==0




        allScenario_IDS=doMove(allScenario_IDS,MOVE_UP,sigIdToMove);

    else




        siblingIdsInOrder=getChildrenIDsInSiblingOrder(repoUtil,sourceParentID);


        siblingIdsInOrder=doMove(siblingIdsInOrder,MOVE_UP,sigIdToMove);

        childMgr=sta.ChildManager;
        childOrderIDS=getChildOrderIDs(childMgr,sourceParentID);

        eng=sdi.Repository(true);
        eng.safeTransaction(@updateRepositoryOrder,...
        childOrderIDS,...
        siblingIdsInOrder);


        oldestParent=repoUtil.getOldestRelative(sigIdToMove);


        repoUtil.setMetaDataByName(sigIdToMove,'IS_EDITED',1);


        if oldestParent~=0
            repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
        end

    end

    if RE_ORDER_TREE
        arrayOfProps=Simulink.sta.signaltree.rearrangeTreeOrder(allScenario_IDS,[],0);
    else
        arrayOfProps=[];
    end

    function allIDs=doMove(allIDs,MOVE_UP,sigIdToMove)

        if MOVE_UP

            idx_up=find((allIDs==sigIdToMove)==1);
            idx_down=idx_up-1;

            if idx_up==1
                return
            end

            val_up=allIDs(idx_up);
            allIDs(idx_up)=allIDs(idx_down);
            allIDs(idx_down)=val_up;
        else

            idx_down=find((allIDs==sigIdToMove)==1);
            idx_up=idx_down+1;

            if idx_down==length(allIDs)
                return
            end

            val_up=allIDs(idx_up);
            allIDs(idx_up)=allIDs(idx_down);
            allIDs(idx_down)=val_up;
        end

        function updateRepositoryOrder(childOrderIDS,siblingIdsInOrder)

            for k=1:length(childOrderIDS)
                childOrder=sta.ChildOrder(childOrderIDS(k));
                childOrder.ChildID=siblingIdsInOrder(k);
            end
