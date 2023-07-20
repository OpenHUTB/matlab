function[WAS_SUCCESSFUL,errMsg,returnID,jsonStruct]=copySignal(sigIDToCopy,namesCantBeUsed,currentTreeOrderMax,fileName,appInstanceID,baseMsg,varargin)



    WAS_SUCCESSFUL=false;
    errMsg='';

    if isempty(fileName)
        fileName='';
    end
    RE_ORDER_TREE=true;
    PUBLISH_RESULTS=true;
    if~isempty(varargin)
        RE_ORDER_TREE=varargin{1};

        if length(varargin)>1
            PUBLISH_RESULTS=varargin{2};
        else
            PUBLISH_RESULTS=true;
        end
    end



    msgTopics=Simulink.sta.EditorTopics();
    msgOut.spinnerID='duplicate';
    msgOut.spinnerOn=true;
    fullChannelSPINNER=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.SPINNER);

    if PUBLISH_RESULTS
        message.publish(fullChannelSPINNER,msgOut);
    end
    msgOut.spinnerOn=false;

    repoUtil=starepository.RepositoryUtility();

    try
        signalNameToCopy=getVariableName(repoUtil,sigIDToCopy);
        simulinkSignal=getSimulinkSignalByID(repoUtil,sigIDToCopy);

        aStrUtil=sta.StringUtil();
        for k=1:length(namesCantBeUsed)
            aStrUtil.addNameContext(namesCantBeUsed{k});
        end

        signalNameToCopy=aStrUtil.getUniqueName(signalNameToCopy);

    catch ME
        errMsg=ME.message;
        return;
    end


    if(isempty(simulinkSignal)||isstruct(simulinkSignal)&&isempty(fieldnames(simulinkSignal)))&&(contains(repoUtil.getMetaDataByName(sigIDToCopy,'dataformat'),'bus')&&~contains(repoUtil.getMetaDataByName(sigIDToCopy,'dataformat'),'groundorpartialspecifiedbus'))
        itemFactory=starepository.factory.MATLABStructBusItem(signalNameToCopy,simulinkSignal);
        item=itemFactory.createSignalItemWithoutChildren;
    else

        itemFactory=starepository.factory.createSignalItemFactory(signalNameToCopy,simulinkSignal);

        item=itemFactory.createSignalItem;
    end


    eng=sdi.Repository(true);

    jsonStruct=eng.safeTransaction(@starepository.ioitem.initStreaming,{item},fileName,currentTreeOrderMax);

    aFactory=starepository.repositorysignal.Factory;

    concreteExtractor=aFactory.getSupportedExtractor(sigIDToCopy);

    jsonStructFromRepo=jsonStructFromID(concreteExtractor,sigIDToCopy);
    aRepoUtil=starepository.RepositoryUtility;


    for kSig=1:length(jsonStruct)

        idForMeta=jsonStructFromRepo{kSig}.ID;
        if isfield(jsonStructFromRepo{kSig},'ComplexID')
            idForMeta=jsonStructFromRepo{kSig}.ComplexID;
        end

        meta_Data=aRepoUtil.getMetaDataStructure(idForMeta);

        structFieldNames=fieldnames(meta_Data);

        idForSetMeta=jsonStruct{kSig}.ID;
        if isfield(jsonStruct{kSig},'ComplexID')
            idForSetMeta=jsonStruct{kSig}.ComplexID;
        end

        for k=1:length(structFieldNames)

            aRepoUtil.setMetaDataByName(idForSetMeta,structFieldNames{k},meta_Data.(structFieldNames{k}))
        end
    end


    for kStruct=1:length(jsonStruct)
        jsonStruct{kStruct}.TreeOrder=currentTreeOrderMax+kStruct;
    end


    copiedSignalParentID=getParent(repoUtil,sigIDToCopy);



    repoUtil.setMetaDataByName(jsonStruct{1}.ID,'IS_EDITED',1);

    if isfield(jsonStruct{1},'ComplexID')
        repoUtil.setMetaDataByName(jsonStruct{1}.ComplexID,'IS_EDITED',1);
    end



    oldestParent=repoUtil.getOldestRelative(sigIDToCopy);


    if(oldestParent~=0)&&(oldestParent~=sigIDToCopy)
        repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
    end

    repoManager=sta.RepositoryManager;
    scenarioID=getScenarioIDByAppID(repoManager,appInstanceID);

    allScenario_IDS=getTopLevelIDsInTreeOrder(repoUtil,scenarioID);

    if copiedSignalParentID==0

        eng=sdi.Repository(true);
        eng.safeTransaction(@initExternalSources,...
        jsonStruct,...
        scenarioID);

        if isfield(jsonStruct{1},'ComplexID')
            sigScenarioID=jsonStruct{1}.ComplexID;
        else
            sigScenarioID=jsonStruct{1}.ID;
        end

        allScenario_IDS=[allScenario_IDS,sigScenarioID];

        N_SCENARIOS=length(allScenario_IDS);

        k=1;
        scenarioPointer=1;
        tempScenarios=-1*ones(1,N_SCENARIOS);
        while k<=N_SCENARIOS
            tempScenarios(k)=allScenario_IDS(scenarioPointer);

            if allScenario_IDS(k)==sigIDToCopy
                k=k+1;
                tempScenarios(k)=allScenario_IDS(end);
            end

            k=k+1;
            scenarioPointer=scenarioPointer+1;

        end

        allScenario_IDS=tempScenarios;
    end

    arrayOfProps=[];


    if copiedSignalParentID~=0

        lineageIDS(1)=repoUtil.getParent(sigIDToCopy);
        aParentID=lineageIDS(1);
        while aParentID~=0
            aParentID=repoUtil.getParent(lineageIDS(length(lineageIDS)));
            if aParentID~=0
                lineageIDS(length(lineageIDS)+1)=aParentID;%#ok<AGROW>
            end
        end

        parentFullName=repoUtil.getSignalLabel(lineageIDS(length(lineageIDS)));
        for k=length(lineageIDS)-1:-1:1
            parentFullName=[parentFullName,'.',repoUtil.getSignalLabel(lineageIDS(k))];%#ok<AGROW>
        end



        moveInsertID=double(jsonStruct{1}.ID);

        if isfield(jsonStruct{1},'ComplexID')
            moveInsertID=jsonStruct{1}.ComplexID;
        end



        arrayOfProps=Simulink.sta.signaltree.moveAndInsertSignal(double(allScenario_IDS),moveInsertID,double(copiedSignalParentID),...
        parentFullName,'','');


        copiedParentChildren=getChildrenIDsInSiblingOrder(repoUtil,copiedSignalParentID);


        N_CHILDREN=length(copiedParentChildren);

        k=1;
        childPointer=1;
        tempChildren=-1*ones(1,N_CHILDREN);
        while k<=N_CHILDREN
            tempChildren(k)=copiedParentChildren(childPointer);

            if copiedParentChildren(k)==sigIDToCopy
                k=k+1;
                tempChildren(k)=copiedParentChildren(end);
            end

            k=k+1;
            childPointer=childPointer+1;

        end

        childMgr=sta.ChildManager;
        childOrderIDS=getChildOrderIDs(childMgr,copiedSignalParentID);

        for k=1:length(childOrderIDS)
            childOrder=sta.ChildOrder(childOrderIDS(k));
            childOrder.ChildID=tempChildren(k);
        end

        jsonStruct{1}.ParentID=copiedSignalParentID;

    end


    if RE_ORDER_TREE

        arrayOfProps=Simulink.sta.signaltree.rearrangeTreeOrder(double(allScenario_IDS),arrayOfProps,0);
    end




    msgTopics=Simulink.sta.EditorTopics();


    fullChannel=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.SIGNAL_EDIT);
    fullChannelSigUpdated=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.ID_TO_REPORT);

    fullChannelPropUpdated=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.ITEM_PROP_UPDATE);

    outdata.arrayOfListItems=jsonStruct;
    outdata.editted_id=[];

    if PUBLISH_RESULTS
        message.publish(fullChannel,outdata);
        message.publish(fullChannelSigUpdated,jsonStruct{1}.ID);
        message.publish(fullChannelPropUpdated,arrayOfProps);
        message.publish(fullChannelSPINNER,msgOut);
    end
    returnID=jsonStruct{1}.ID;

    if isfield(jsonStruct{1},'ComplexID')
        returnID=jsonStruct{1}.ComplexID;
    end

    WAS_SUCCESSFUL=true;

