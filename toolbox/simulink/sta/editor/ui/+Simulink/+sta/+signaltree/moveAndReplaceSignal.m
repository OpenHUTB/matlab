function[arrayOfProps,undoProperties,destID]=moveAndReplaceSignal(scenarioIDs,sourceID,destID,parentFullName,baseMsg,appInstanceID,varargin)






    repoUtil=starepository.RepositoryUtility();


    sourceParentID=getParent(repoUtil,sourceID);
    destParentID=getParent(repoUtil,destID);

    siblingIdsInOrder=getChildrenIDsInSiblingOrder(repoUtil,sourceParentID);
    undoProperties.originalMovedSiblingOrder=siblingIdsInOrder;

    siblingIdsInOrder=getChildrenIDsInSiblingOrder(repoUtil,destParentID);
    undoProperties.originalTargetSiblingOrder=siblingIdsInOrder;
    undoProperties.originalTargetParent=destParentID;

    transformLoggedSignalsForContainer(repoUtil,sourceID,destParentID);



    destParentFormatType=getMetaDataByName(repoUtil,destParentID,'dataformat');


    foundanyBusFormIDX=strfind(destParentFormatType,'busstructure');
    foundanyAOBBusFormIDX=strfind(destParentFormatType,'aobbusstructure');


    if sourceParentID==0

        sourceParentFormatType='';
        sourceGrandParentFormatType='';


        scenarioIDs(scenarioIDs==sourceID)=[];
    else


    end


    RE_ORDER_TREE=true;

    if~isempty(varargin)
        RE_ORDER_TREE=varargin{1};
    end




    msgTopics=Simulink.sta.EditorTopics();
    fullChannel=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.REMOVE_SIGNAL_AND_DESCENDANTS);
    removeStruct.idToRemove=destID;

    signalTypeDest=getMetaDataByName(repoUtil,destID,'SignalType');
    IS_COMPLEX_DEST=strcmp(signalTypeDest,getString(message('sl_sta_general:common:Complex')));

    if(IS_COMPLEX_DEST)
        siblingIdsInOrder_Destination=getChildrenIDsInSiblingOrder(repoUtil,destID);
        removeStruct.idToRemove=siblingIdsInOrder_Destination(1);
    end

    message.publish(fullChannel,removeStruct);

    undoProperties.removeStruct=removeStruct;

    if foundanyAOBBusFormIDX

    else

        childMgr=sta.ChildManager;
        childMgr.remove(sourceID);


        replaceChild(repoUtil,destID,sourceID);



    end

    if RE_ORDER_TREE

        arrayOfProps=Simulink.sta.signaltree.rearrangeTreeOrder(scenarioIDs,[],0);
    else
        arrayOfProps=[];
    end
    nProps=length(arrayOfProps)+1;

    signalType=getMetaDataByName(repoUtil,sourceID,'SignalType');
    IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));

    if~IS_COMPLEX
        arrayOfProps(nProps).id=sourceID;
        arrayOfProps(nProps).propertyname='ParentID';
        arrayOfProps(nProps).newValue=destParentID;
        arrayOfProps(nProps+1).id=sourceID;
        arrayOfProps(nProps+1).propertyname='parent';
        arrayOfProps(nProps+1).newValue=destParentID;
        arrayOfProps(nProps+2).id=sourceID;
        arrayOfProps(nProps+2).propertyname='ParentName';
        arrayOfProps(nProps+2).newValue=getSignalLabel(repoUtil,destParentID);
        arrayOfProps(nProps+3).id=sourceID;
        arrayOfProps(nProps+3).propertyname='FullName';
        arrayOfProps(nProps+3).newValue=[parentFullName,'.',getSignalLabel(repoUtil,sourceID)];
    else
        signalChildrenIDs=getChildrenIDsInSiblingOrder(repoUtil,sourceID);

        arrayOfProps(nProps).id=signalChildrenIDs(1);
        arrayOfProps(nProps).propertyname='ParentID';
        arrayOfProps(nProps).newValue=destParentID;
        arrayOfProps(nProps+1).id=signalChildrenIDs(1);
        arrayOfProps(nProps+1).propertyname='parent';
        arrayOfProps(nProps+1).newValue=destParentID;
        arrayOfProps(nProps+2).id=signalChildrenIDs(1);
        arrayOfProps(nProps+2).propertyname='ParentName';
        arrayOfProps(nProps+2).newValue=getSignalLabel(repoUtil,destParentID);
        arrayOfProps(nProps+3).id=signalChildrenIDs(1);
        arrayOfProps(nProps+3).propertyname='FullName';
        arrayOfProps(nProps+3).newValue=parentFullName;
    end

    childArrayOfProps=Simulink.sta.signaltree.updateChildFullName(sourceID,arrayOfProps(nProps+3).newValue);
    arrayOfProps=[arrayOfProps,childArrayOfProps];


    oldestParent=repoUtil.getOldestRelative(sourceID);


    repoUtil.setMetaDataByName(sourceID,'IS_EDITED',1);


    if oldestParent~=0
        repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
    end


    oldestParent=repoUtil.getOldestRelative(destID);


    repoUtil.setMetaDataByName(destID,'IS_EDITED',1);


    if oldestParent~=0
        repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
    end
