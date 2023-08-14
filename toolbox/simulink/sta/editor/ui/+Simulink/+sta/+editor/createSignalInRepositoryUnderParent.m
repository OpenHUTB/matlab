function[jsonStruct,arrayOfProps]=createSignalInRepositoryUnderParent(item,fileName,currentTreeOrderMax,scenarioID,parentIDToAssign,parentFullName)



    eng=sdi.Repository(true);

    if isempty(fileName)
        fileName='';
    end

    jsonStruct=eng.safeTransaction(@starepository.ioitem.initStreaming,{item},fileName,currentTreeOrderMax);


    theScenarioRepoItem=sta.Scenario(scenarioID);
    topLevelSignalIDs=getSignalIDs(theScenarioRepoItem);

    repoUtil=starepository.RepositoryUtility();

    for kStruct=1:length(jsonStruct)
        repoUtil.setMetaDataByName(jsonStruct{kStruct}.ID,'IS_EDITED',1);

        if isfield(jsonStruct{kStruct},'ComplexID')
            repoUtil.setMetaDataByName(jsonStruct{kStruct}.ComplexID,'IS_EDITED',1);
        end
    end

    aFactory=starepository.repositorysignal.Factory;

    signalIDToPlace=jsonStruct{1}.ID;
    if isfield(jsonStruct{1},'ComplexID')
        signalIDToPlace=jsonStruct{1}.ComplexID;
    end

    concreteExtractor=aFactory.getSupportedExtractor(signalIDToPlace);
    parentIDToAssign=findFirstPossibleParent(concreteExtractor,signalIDToPlace,parentIDToAssign);


    if parentIDToAssign~=0


        arrayOfProps=Simulink.sta.signaltree.moveAndInsertSignal(double(topLevelSignalIDs),double(signalIDToPlace),double(parentIDToAssign),...
        parentFullName,'','');


        repoUtil.setMetaDataByName(signalIDToPlace,'IS_EDITED',1);

        oldestParent=repoUtil.getOldestRelative(jsonStruct{1}.ID);


        if oldestParent~=0
            repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
        end
    else

        eng=sdi.Repository(true);
        eng.safeTransaction(@initExternalSources,...
        jsonStruct,...
        scenarioID);

        arrayOfProps=Simulink.sta.signaltree.rearrangeTreeOrder(double(topLevelSignalIDs),[],0);


        repoUtil.setMetaDataByName(signalIDToPlace,'IS_EDITED',1);
    end


    for kSig=1:length(arrayOfProps)


        for kJson=1:length(jsonStruct)


            if(arrayOfProps(kSig).id==jsonStruct{kJson}.ID)


                jsonStruct{kJson}.(arrayOfProps(kSig).propertyname)=...
                arrayOfProps(kSig).newValue;
                break;
            end

        end

    end
