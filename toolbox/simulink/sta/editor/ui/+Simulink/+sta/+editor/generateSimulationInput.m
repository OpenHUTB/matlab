function[errMsg,inputID]=generateSimulationInput(model,sigName,namesInUse,currentTreeOrderMax,fileName,appInstanceID,baseMsg)








    errMsg=[];
    inputID=[];


    if~isvarname(sigName)

        sigName=matlab.lang.makeValidName(sigName);
    end

    if isempty(fileName)
        fileName='';
    end


    aStrUtil=sta.StringUtil();
    for k=1:length(namesInUse)
        aStrUtil.addNameContext(namesInUse{k});
    end

    sigName=aStrUtil.getUniqueName(sigName);

    try
        ds=createInputDataset(model);
    catch ME
        [~,errMsg]=loc_resolveCreateError(ME);
        return;
    end



    itemFactory=starepository.factory.createSignalItemFactory(sigName,ds);

    item=itemFactory.createSignalItem;

    eng=sdi.Repository(true);

    jsonStruct=eng.safeTransaction(@starepository.ioitem.initStreaming,{item},fileName,currentTreeOrderMax);

    inputID=jsonStruct{1}.ID;

    repoManager=sta.RepositoryManager();
    scenarioID=getScenarioIDByAppID(repoManager,appInstanceID);

    eng=sdi.Repository(true);
    eng.safeTransaction(@initExternalSources,...
    jsonStruct,...
    scenarioID);


    msgTopics=Simulink.sta.EditorTopics();


    fullChannel=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.SIGNAL_EDIT);

    outdata.arrayOfListItems=jsonStruct;

    message.publish(fullChannel,outdata);
end


function[errID,errMsg]=loc_resolveCreateError(ME)

    if~isempty(ME.cause)
        [errID,errMsg]=loc_resolveBusCreateError(ME.cause{1});
    else
        errID=ME.identifier;
        errMsg=ME.message;
    end
end


function[errID,errMsg]=loc_resolveBusCreateError(ME)

    errID='';%#ok<NASGU>
    errMsg='';%#ok<NASGU>

    if~isempty(ME.cause)
        [errID,errMsg]=loc_resolveBusCreateError(ME.cause{1});
    else
        errID=ME.identifier;
        errMsg=ME.message;
    end
end
