


function addedSignalIDs=addData(rowIDs,checkedValue,runID,blockID,source)

    ctrlObj=locGetCtrlObj(blockID);


    ctrlObj.close();


    locPublishToClient(ctrlObj,'showSpinner');


    if strcmp(string(source),"workspace")
        addedSignalIDs=addWorkSpaceSignalsToBlock(rowIDs,checkedValue,runID,ctrlObj);
    elseif strcmp(string(source),"dataInspector")
        addedSignalIDs=addSDISignalsToBlock(rowIDs,runID,ctrlObj);
    else
        addedSignalIDs=addFileSignalsToBlock(rowIDs,checkedValue,runID,ctrlObj,source);
    end


    if~isempty(addedSignalIDs)
        locHideEmptyState(ctrlObj);
    end


    locPublishToClient(ctrlObj,'hideSpinner');
end


function addedSignalIDs=addWorkSpaceSignalsToBlock(rowIDs,checkedValue,runID,ctrlObj)
    ctrlObj.updateCheckedStateInHierarchicalData(rowIDs,checkedValue);
    repo=sdi.Repository(1);
    try
        addedSignalIDs=[];
        existingSignalIDs=repo.getAllSignalIDs(runID,'all');
        mdlName='';
        overwrittenRunID=0;
        parentRunID=int32.empty;
        addToRun(ctrlObj.Engine.WksParser,...
        ctrlObj.Engine,runID,ctrlObj.VarParser,mdlName,...
        overwrittenRunID,parentRunID,'OneRun',true);
        currentSignalIDs=repo.getAllSignalIDs(runID,'all');
        index=1;
        numOfSignalsAdded=numel(currentSignalIDs)-numel(existingSignalIDs);
        addedSignalIDs=repelem(int32(0),numOfSignalsAdded);
        for i=numel(existingSignalIDs)+1:numel(currentSignalIDs)
            addedSignalIDs(index)=currentSignalIDs(i);
            index=index+1;
        end
        ctrlObj.Engine.WksParser.resetParser();
    catch me

        displayMessageBox(me.message,ctrlObj.ClientID);
    end
end


function addedSignalIDs=addFileSignalsToBlock(rowIDs,checkedValue,runID,ctrlObj,fileName)
    ctrlObj.updateCheckedStateInHierarchicalData(rowIDs,checkedValue);
    repo=sdi.Repository(1);
    try
        addedSignalIDs=[];
        existingSignalIDs=repo.getAllSignalIDs(runID,'all');
        runName=Simulink.sdi.getRun(runID).Name;
        importer=Simulink.sdi.internal.import.FileImporter.getDefault();
        importer.verifyFileAndImport(...
        sdi.Repository(1),...
        fileName,runName,...
        true,...
        runID,...
        'reader','',...
        'parser',ctrlObj.VarParser,...
        'OneRun',true);

        currentSignalIDs=repo.getAllSignalIDs(runID,'all');
        index=1;
        numOfSignalsAdded=numel(currentSignalIDs)-numel(existingSignalIDs);
        addedSignalIDs=repelem(int32(0),numOfSignalsAdded);
        for i=numel(existingSignalIDs)+1:numel(currentSignalIDs)
            addedSignalIDs(index)=currentSignalIDs(i);
            index=index+1;
        end
        ctrlObj.Engine.WksParser.resetParser();
    catch me

        clientID=get_param(ctrlObj.Config.BlockPath,'clientId');
        displayMessageBox(me.message,clientID);
    end
end


function addedSignalIDs=addSDISignalsToBlock(signalIDs,runID,ctrlObj)
    try
        addedSignalIDs=[];
        numOfSignalsToAdd=numel(signalIDs);
        sigIDs=repelem(int32(0),numOfSignalsToAdd);
        for i=1:numOfSignalsToAdd
            sigIDs(i)=int32(signalIDs(i));
        end
        addedSignalIDs=Simulink.playback.internal.addSDISignalsToRun(sigIDs,runID);
    catch me

        clientID=get_param(ctrlObj.Config.BlockPath,'clientId');
        displayMessageBox(me.message,clientID);
    end
end


function displayMessageBox(erroMsg,clientID)
    titleStr=getString(message('record_playback:errors:AddError'));
    okStr=getString(message('record_playback:playbackui:OK'));
    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.displayMsgBox(...
    'playback',...
    titleStr,...
    erroMsg,...
    {okStr},...
    0,...
    -1,...
    [],...
    'clientID',clientID);
end


function locHideEmptyState(ctrlObj)
    sigMetadata=get_param(ctrlObj.Config.BlockPath,'signalMetadata');

    if isempty(sigMetadata)
        locPublishToClient(ctrlObj,'hideEmptyState');
    end
end


function locPublishToClient(ctrlObj,msg)
    dispatcher=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
    clientID=get_param(ctrlObj.Config.BlockPath,'clientId');
    dispatcher.publishToClient(clientID,'mainApp',msg,[]);
end


function ctrlObj=locGetCtrlObj(blockID)
    config=[];
    config.BlockId=blockID;
    mainApp=Simulink.playback.mainApp.getController(config);
    ctrlObj=mainApp.AddDataUi;
end