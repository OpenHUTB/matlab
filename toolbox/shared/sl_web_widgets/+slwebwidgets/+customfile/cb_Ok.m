function[was_successful_struct,topLevelIDs]=cb_Ok(State,appInstanceID)





    was_successful_struct.was_successful=false;
    was_successful_struct.errMsg='';

    outdata=[];
    outdataStruct.outdata=outdata;
    topLevelIDs=[];




    aList=squeeze(State.selectedIndices);


    for k=1:length(aList)

        if~isvarname(aList(k).name)
            aList(k).name=matlab.lang.makeValidName(deblank(aList(k).name));
        end

    end

    fullFilePath=which(State.matFile);


    if isempty(fullFilePath)

        fullFilePath=State.matFile;
    end

    try
        aFileObj=Simulink.io.FileTypeFactory.getInstance().createReader(fullFilePath,State.readerName);
        [jsonStruct,SDIrunID]=import2Repository(aFileObj,aList,State.startTreeOrder,State.namesInUse);
    catch ME_IMPORT

        was_successful_struct.errMsg=ME_IMPORT.message;
        was_successful_struct.was_successful=false;
        return;
    end

    msgTopics=Simulink.sta.EditorTopics();


    repoMgr=sta.RepositoryManager;
    scenarioID=getScenarioIDByAppID(repoMgr,appInstanceID);
    theScenarioRepoItem=sta.Scenario(scenarioID);
    topLevelSignalIDs=getSignalIDs(theScenarioRepoItem);

    eng=sdi.Repository(true);
    eng.safeTransaction(@initExternalSources,...
    jsonStruct,...
    scenarioID);

    arrayOfProps=Simulink.sta.signaltree.rearrangeTreeOrder(double(topLevelSignalIDs),[],0);


    for kSig=1:length(arrayOfProps)


        for kJson=1:length(jsonStruct)


            if(arrayOfProps(kSig).id==jsonStruct{kJson}.ID)


                jsonStruct{kJson}.(arrayOfProps(kSig).propertyname)=...
                arrayOfProps(kSig).newValue;
                break;
            end

        end

    end

    was_successful=true;

    outdata.arrayOfListItems=jsonStruct;

    msgTopics=Simulink.sta.EditorTopics();
    fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,appInstanceID,msgTopics.SIGNAL_EDIT);
    message.publish(fullChannel,outdata);

    fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,appInstanceID,msgTopics.ITEM_PROP_UPDATE);
    message.publish(fullChannel,arrayOfProps);

    topLevelIDs=[];
    for k=1:length(jsonStruct)

        if ischar(jsonStruct{k}.ParentID)&&...
            strcmpi(jsonStruct{k}.ParentID,'input')

            topLevelIDs(length(topLevelIDs)+1)=jsonStruct{k}.ID;%#ok<AGROW>

        end

    end

    was_successful_struct.was_successful=true;

end

