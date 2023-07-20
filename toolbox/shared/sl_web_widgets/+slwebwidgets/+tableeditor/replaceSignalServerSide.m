function replaceSignalServerSide(sigID,newJsonStruct,appInstanceID)





    repoUtil=starepository.RepositoryUtility();




    parentID=repoUtil.repo.getSignalParent(sigID);


    fileToWriteUpdateTo=repoUtil.getMetaDataByName(sigID,'LastKnownFullFile');


    if parentID~=0

        parentSignalName=repoUtil.repo.getSignalName(parentID);

        setMetaDataByName(repoUtil,newJsonStruct{1}.ID,'ParentName',parentSignalName);

        if isfield(newJsonStruct{1},'ComplexID')
            setMetaDataByName(repoUtil,newJsonStruct{1}.ComplexID,'ParentName',parentSignalName);
        end


        fileToWriteUpdateTo=repoUtil.getMetaDataByName(parentID,'LastKnownFullFile');
    end

    if isempty(fileToWriteUpdateTo)
        fileToWriteUpdateTo='';%#ok<NASGU>
    end


    treeOrder=getMetaDataByName(repoUtil,sigID,'TreeOrder');


    jsonStruct=newJsonStruct;
    for kChild=1:length(jsonStruct)
        jsonStruct{kChild}.TreeOrder=treeOrder;
        setMetaDataByName(repoUtil,jsonStruct{kChild}.ID,'TreeOrder',treeOrder);

        if isfield(jsonStruct{kChild},'ComplexID')
            setMetaDataByName(repoUtil,jsonStruct{kChild}.ComplexID,'TreeOrder',treeOrder);
        end
        treeOrder=treeOrder+1;
    end



    if parentID~=0


        replaceChild(repoUtil,sigID,jsonStruct{1}.ID);
        jsonStruct{1}.ParentID=parentID;

        setMetaDataByName(repoUtil,jsonStruct{1}.ID,'ParentID',parentID);

    end

    outdata.arrayOfListItems=jsonStruct;

    childIds=getChildrenIds(repoUtil,sigID);

    if isempty(childIds)
        outdata.editted_id=sigID;
        outdata.from_cast=true;
    else
        outdata.editted_id=[sigID,childIds];
        outdata.from_cast=true;
    end


    msgTopics=Simulink.sta.EditorTopics();

    fullChannel=sprintf('/staeditor%s/%s',appInstanceID,msgTopics.SIGNAL_EDIT);
    fullChannelSigUpdated=sprintf('/staeditor%s/%s',appInstanceID,msgTopics.ID_TO_REPORT);

    message.publish(fullChannel,outdata);
    message.publish(fullChannelSigUpdated,sigID);
