function[arrayOfProps,errMessage,undoProperties]=moveAndInsertSignal(scenarioIDs,sourceID,destID,...
    parentFullName,baseMsg,appInstanceID,varargin)




    errMessage='';
    repoUtil=starepository.RepositoryUtility();
    transformLoggedSignalsForContainer(repoUtil,sourceID,destID);

    sourceSignalName=getSignalLabel(repoUtil,sourceID);


    sourceParentID=getParent(repoUtil,sourceID);
    targetParentID=getParent(repoUtil,destID);

    undoProperties.movedID=sourceID;
    undoProperties.originalMovedParent=sourceParentID;
    undoProperties.originalTargetParent=destID;
    undoProperties.originalTargetGrandParent=targetParentID;

    siblingIdsInOrder=getChildrenIDsInSiblingOrder(repoUtil,sourceParentID);
    undoProperties.originalMovedSiblingOrder=siblingIdsInOrder;

    siblingIdsInOrder=getChildrenIDsInSiblingOrder(repoUtil,destID);
    undoProperties.originalTargetSiblingOrder=siblingIdsInOrder;

    targetFormatType=getMetaDataByName(repoUtil,destID,'dataformat');

    RE_ORDER_TREE=true;

    if~isempty(varargin)
        RE_ORDER_TREE=varargin{1};
    end


    if contains(targetFormatType,'bus')&&~isvarname(sourceSignalName)


        arrayOfProps=[];
        errMessage=DAStudio.message('sl_sta:editor:dragNDropVarName');
        return;

    end

    if sourceParentID==0
        sourceParentFormatType='';
        sourceGrandParentFormatType='';


        scenarioIDs(scenarioIDs==sourceID)=[];

        repoManager=sta.RepositoryManager();
        scenarioid=getScenarioIDByAppID(repoManager,appInstanceID);
        removeExternalSourceFromScenario(repoManager,scenarioid,sourceID);

    else

        removeParent(repoUtil,sourceID);

        sourceParentFormatType=getMetaDataByName(repoUtil,sourceParentID,'dataformat');
        sourceGrandParentID=getParent(repoUtil,sourceParentID);

        if sourceGrandParentID==0
            sourceGrandParentFormatType='';
        else
            sourceGrandParentFormatType=getMetaDataByName(repoUtil,sourceGrandParentID,'dataformat');
        end
    end

    if targetParentID==0
        destParentFormatType='';
    else
        destParentFormatType=getMetaDataByName(repoUtil,targetParentID,'dataformat');
    end


    insertChildAtBottom(repoUtil,sourceID,destID);
    setMetaDataByName(repoUtil,sourceID,'ParentID',destID);


    if strcmpi(destParentFormatType,'aobbusstructure')






        targetParentChildren=getChildrenIDsInSiblingOrder(repoUtil,targetParentID);


        targetParentChildren(targetParentChildren==destID)=[];

        newSigName=getSignalLabel(repoUtil,sourceID);
        owningFile=getMetaDataByName(repoUtil,sourceID,'FileName');
        eng=sdi.Repository(true);
        sigStruct=cell(1,length(targetParentChildren));
        for kTarget=1:length(targetParentChildren)

            factory=starepository.factory.createSignalItemFactory(newSigName,[]);
            act_item=factory.createSignalItem();



            tmpsigStruct=eng.safeTransaction(@starepository.ioitem.initStreaming,{act_item},owningFile,1);

            sigStruct{kTarget}=tmpsigStruct{1};
            sigStruct{kTarget}.ParentID=targetParentChildren(kTarget);
            sigStruct{kTarget}.parent=targetParentChildren(kTarget);
            sigStruct{kTarget}.ParentName=getSignalLabel(repoUtil,targetParentChildren(kTarget));


            if~isempty(getQueue(act_item))
                Simulink.AsyncQueue.Queue.configureQueuesAndLaunchThreads(getQueue(act_item));
            end
            streamToRepository(act_item);


            insertChildAtBottom(repoUtil,sigStruct{kTarget}.ID,targetParentChildren(kTarget));
            setMetaDataByName(repoUtil,sigStruct{kTarget}.ID,'ParentID',targetParentChildren(kTarget));


        end



        msgTopics=Simulink.sta.EditorTopics();
        fullChannel=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.SIGNAL_INSERT);
        message.publish(fullChannel,sigStruct);
    end


    if strcmpi(sourceGrandParentFormatType,'aobbusstructure')

        sourceGrandParentChildren=getChildrenIDsInSiblingOrder(repoUtil,sourceGrandParentID);
        idsToRemove=[];


        for kSourceGPKids=1:length(sourceGrandParentChildren)

            kiddies=getChildrenIDsInSiblingOrder(repoUtil,sourceGrandParentChildren(kSourceGPKids));

            for theKids=1:length(kiddies)


                sourceGPChildName=getSignalLabel(repoUtil,kiddies(theKids));

                if strcmp(sourceGPChildName,sourceSignalName)
                    idsToRemove=[idsToRemove...
                    ,Simulink.sta.editor.deleteSignal(kiddies(theKids),...
                    appInstanceID,baseMsg)];
                end
            end

        end




        msgTopics=Simulink.sta.EditorTopics();
        fullChannel=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.DELETE);
        removeStruct.idsToRemove=idsToRemove;
        message.publish(fullChannel,removeStruct);
    end

    if RE_ORDER_TREE
        arrayOfProps=rearrangeTreeOrder(repoUtil,scenarioIDs,[],0);
    else
        arrayOfProps=[];
    end
    nProps=length(arrayOfProps)+1;

    signalType=getMetaDataByName(repoUtil,sourceID,'SignalType');
    IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));

    if~IS_COMPLEX
        arrayOfProps(nProps).id=sourceID;
        arrayOfProps(nProps).propertyname='ParentID';
        arrayOfProps(nProps).newValue=destID;
        arrayOfProps(nProps+1).id=sourceID;
        arrayOfProps(nProps+1).propertyname='parent';
        arrayOfProps(nProps+1).newValue=destID;
        arrayOfProps(nProps+2).id=sourceID;
        arrayOfProps(nProps+2).propertyname='ParentName';
        arrayOfProps(nProps+2).newValue=getSignalLabel(repoUtil,destID);
        arrayOfProps(nProps+3).id=sourceID;
        arrayOfProps(nProps+3).propertyname='FullName';
        arrayOfProps(nProps+3).newValue=[parentFullName,'.',getSignalLabel(repoUtil,sourceID)];

        childArrayOfProps=Simulink.sta.signaltree.updateChildFullName(sourceID,arrayOfProps(nProps+3).newValue);
        arrayOfProps=[arrayOfProps,childArrayOfProps];
    else

        dataFormat=getMetaDataByName(repoUtil,sourceID,'dataformat');
        IS_MULTIDIM=contains(dataFormat,'multidimtimeseries');
        IS_NON_SCALAR_TT=contains(dataFormat,'non_scalar_sl_timetable');
        IS_NDIM=contains(dataFormat,'ndimtimeseries');

        if IS_MULTIDIM

            multiFullName=[parentFullName,'.',getSignalLabel(repoUtil,sourceID)];

            arrayOfProps(nProps).id=sourceID;
            arrayOfProps(nProps).propertyname='ParentID';
            arrayOfProps(nProps).newValue=destID;
            arrayOfProps(nProps+1).id=sourceID;
            arrayOfProps(nProps+1).propertyname='parent';
            arrayOfProps(nProps+1).newValue=destID;
            arrayOfProps(nProps+2).id=sourceID;
            arrayOfProps(nProps+2).propertyname='ParentName';
            arrayOfProps(nProps+2).newValue=getSignalLabel(repoUtil,destID);
            arrayOfProps(nProps+3).id=sourceID;
            arrayOfProps(nProps+3).propertyname='FullName';
            arrayOfProps(nProps+3).newValue=[parentFullName,'.',getSignalLabel(repoUtil,sourceID)];

            childArrayOfProps=Simulink.sta.signaltree.updateChildFullName(sourceID,multiFullName);
            arrayOfProps=[arrayOfProps,childArrayOfProps];


        elseif IS_NON_SCALAR_TT||IS_NDIM

            multiFullName=[parentFullName,'.',getSignalLabel(repoUtil,sourceID)];

            arrayOfProps(nProps).id=sourceID;
            arrayOfProps(nProps).propertyname='ParentID';
            arrayOfProps(nProps).newValue=destID;
            arrayOfProps(nProps+1).id=sourceID;
            arrayOfProps(nProps+1).propertyname='parent';
            arrayOfProps(nProps+1).newValue=destID;
            arrayOfProps(nProps+2).id=sourceID;
            arrayOfProps(nProps+2).propertyname='ParentName';
            arrayOfProps(nProps+2).newValue=getSignalLabel(repoUtil,destID);
            arrayOfProps(nProps+3).id=sourceID;
            arrayOfProps(nProps+3).propertyname='FullName';
            arrayOfProps(nProps+3).newValue=[parentFullName,'.',getSignalLabel(repoUtil,sourceID)];

            childArrayOfProps=Simulink.sta.signaltree.updateChildFullName(sourceID,multiFullName);
            arrayOfProps=[arrayOfProps,childArrayOfProps];
        else
            signalChildrenIDs=getChildrenIDsInSiblingOrder(repoUtil,sourceID);
            arrayOfProps(nProps).id=signalChildrenIDs(1);
            arrayOfProps(nProps).propertyname='ParentID';
            arrayOfProps(nProps).newValue=destID;
            arrayOfProps(nProps+1).id=signalChildrenIDs(1);
            arrayOfProps(nProps+1).propertyname='parent';
            arrayOfProps(nProps+1).newValue=destID;
            arrayOfProps(nProps+2).id=signalChildrenIDs(1);
            arrayOfProps(nProps+2).propertyname='ParentName';
            arrayOfProps(nProps+2).newValue=getSignalLabel(repoUtil,destID);
            arrayOfProps(nProps+3).id=signalChildrenIDs(1);
            arrayOfProps(nProps+3).propertyname='FullName';
            arrayOfProps(nProps+3).newValue=[parentFullName,'.',getSignalLabel(repoUtil,sourceID)];

            childArrayOfProps=Simulink.sta.signaltree.updateChildFullName(sourceID,arrayOfProps(nProps+3).newValue);
            arrayOfProps=[arrayOfProps,childArrayOfProps];
        end
    end





    oldestParent=repoUtil.getOldestRelative(sourceID);


    repoUtil.setMetaDataByName(sourceID,'IS_EDITED',1);


    if sourceParentID~=0
        repoUtil.setMetaDataByName(sourceParentID,'IS_EDITED',1);
    end


    if oldestParent~=0
        repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
    end




    oldestParent=repoUtil.getOldestRelative(destID);


    repoUtil.setMetaDataByName(destID,'IS_EDITED',1);


    if oldestParent~=0
        repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
    end

end
