function[arrayOfProps,jsonStruct]=undoOverwriteDragAndDrop(inputStruct,appInstanceID)




    inputStruct.reorder=false;



    repoUtil=starepository.RepositoryUtility();

    if(inputStruct.originalMovedParent==0)
        repoUtil.removeParent(inputStruct.movedID);
    end

    [arrayOfProps,jsonStruct]=Simulink.sta.signaltree.undoMoveAndReplace(inputStruct,appInstanceID);








    restoreParentID=inputStruct.restoreSignalProperties.parentid;
    restoreDestinationChildOrderById=inputStruct.restoreSignalProperties.undoSiblingIdsOrderedOfOverwrittenParent;
    repoUtil.repo.safeTransaction(@setChildOrder,...
    restoreParentID,...
    restoreDestinationChildOrderById);



    movedParentID=inputStruct.originalMovedParent;
    if movedParentID~=0
        movedDestinationChildOrderById=inputStruct.undoSiblingIdsOrdered;
        repoUtil.repo.safeTransaction(@setChildOrder,...
        movedParentID,...
        movedDestinationChildOrderById);
    end

    tmpArrayOfProps=rearrangeTreeOrder(repoUtil,inputStruct.scenarioids,[],0);

    arrayOfProps=[arrayOfProps,tmpArrayOfProps];

    function setChildOrder(destId,destinationChildOrderById)

        childMgr=sta.ChildManager;
        childOrderIDS=getChildOrderIDs(childMgr,destId);

        numChildren=length(destinationChildOrderById);
        for kChildren=1:numChildren

            childOrder=sta.ChildOrder(childOrderIDS(kChildren));
            childOrder.ChildID=destinationChildOrderById(kChildren);
            childOrder.SignalOrder=kChildren;


        end
