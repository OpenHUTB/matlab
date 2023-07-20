function[arrayOfProps,originalSiblingIDsInOrder]=orderChildSignal(sigIdToMove,signalIDOfReference,IS_BEFORE,baseMsg,appInstanceID,varargin)



    arrayOfProps=[];


    repoManager=sta.RepositoryManager;
    scenarioID=getScenarioIDByAppID(repoManager,appInstanceID);

    repoUtil=starepository.RepositoryUtility();


    sourceParentID=getParent(repoUtil,sigIdToMove);


    siblingIdsInOrder=getChildrenIDsInSiblingOrder(repoUtil,sourceParentID);
    originalSiblingIDsInOrder=siblingIdsInOrder;


    idx_OfSigToMove=find(siblingIdsInOrder==sigIdToMove,1);
    idx_OfReferenceSig=find(siblingIdsInOrder==signalIDOfReference);


    LENGTH_OF_ITEMS=length(siblingIdsInOrder);
    ID_TO_MOVE=siblingIdsInOrder(idx_OfSigToMove);
    siblingIdsInOrder(idx_OfSigToMove)=NaN;

    if IS_BEFORE

        if idx_OfReferenceSig==1
            siblingIdsInOrder=[ID_TO_MOVE,siblingIdsInOrder];
        else
            siblingIdsInOrder=[siblingIdsInOrder(1:idx_OfReferenceSig-1),ID_TO_MOVE,siblingIdsInOrder(idx_OfReferenceSig:end)];
        end

    else


        if LENGTH_OF_ITEMS==idx_OfReferenceSig
            siblingIdsInOrder=[siblingIdsInOrder(1:idx_OfReferenceSig),ID_TO_MOVE];
        else
            siblingIdsInOrder=[siblingIdsInOrder(1:idx_OfReferenceSig),ID_TO_MOVE,siblingIdsInOrder(idx_OfReferenceSig+1:end)];
        end
    end


    siblingIdsInOrder(isnan(siblingIdsInOrder))=[];

    childMgr=sta.ChildManager;
    childOrderIDS=getChildOrderIDs(childMgr,sourceParentID);

    eng=sdi.Repository(true);
    eng.safeTransaction(@updateRepositoryOrder,...
    childOrderIDS,...
    siblingIdsInOrder);

    RE_ORDER_TREE=true;
    if~isempty(varargin)
        RE_ORDER_TREE=varargin{1};
    end

    if RE_ORDER_TREE
        allScenario_IDS=getTopLevelIDsInTreeOrder(repoUtil,scenarioID);
        arrayOfProps=Simulink.sta.signaltree.rearrangeTreeOrder(allScenario_IDS,[],0);
    else
        arrayOfProps=[];
    end



    function updateRepositoryOrder(childOrderIDS,siblingIdsInOrder)

        for k=1:length(childOrderIDS)
            childOrder=sta.ChildOrder(childOrderIDS(k));
            childOrder.ChildID=siblingIdsInOrder(k);
        end
