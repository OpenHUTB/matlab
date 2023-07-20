function returnStruct=updateSignalData(appInstanceID,sigName,sigID,interpMode,dataType,dataFromTable,isEnum)



    returnStruct.workingID=[];
    returnStruct.errorMessage=[];
    IS_INTEGRATING=true;

    IS_FCN_CALL_UPDATE=false;
    IS_COMPLEXITY_CHANGE=false;
    IS_DATA_TYPE_CHANGE=false;

    eng=sdi.Repository(true);
    repoUtil=starepository.RepositoryUtility();


    if isEnum
        dataType=getMetaDataByName(repoUtil,sigID,'EnumName');
        originalDataType=getMetaDataByName(repoUtil,sigID,'EnumName');


        whichEnum=which(dataType);

        if isempty(whichEnum)
            returnStruct.errorMessage=DAStudio.message('sl_sta:editor:enumNotOnPath',dataType);
            return;
        end

        warnFlag=warning('query','MATLAB:class:InvalidEnum');
        warning('OFF','MATLAB:class:InvalidEnum');

        [~,dataValues]=getSignalTimeAndDataValues(repoUtil,sigID);
        warning(warnFlag.state,'MATLAB:class:InvalidEnum');

        if~isenum(dataValues)
            returnStruct.errorMessage=DAStudio.message('sl_sta:editor:enumModified',dataType);
            return;
        end

    else
        originalDataType=getMetaDataByName(repoUtil,sigID,'DataType');
    end


    dataFormat=getMetaDataByName(repoUtil,sigID,'dataformat');
    isDataArray=~isempty(strfind(dataFormat,'dataarray'));

    signalType=getMetaDataByName(repoUtil,sigID,'SignalType');
    WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));


    if~strcmp(originalDataType,'string')

        dataFromTable=Simulink.sta.tableview.conditionDataFromTable(dataFromTable);








    end

    try

        dataCastFcn=str2func(dataType);

        if strcmp(dataType,'string')
            dataVals=dataCastFcn({dataFromTable(:).signaldata});
        else
            dataVals=dataCastFcn([dataFromTable(:).signaldata]);
        end


        isSignalComplex=~isreal(dataVals)&&~isstring(dataVals);

        IS_COMPLEXITY_CHANGE=(isSignalComplex&&WAS_REAL)||(~WAS_REAL&&~isSignalComplex);





        if(isSignalComplex&&WAS_REAL)||(~isSignalComplex&&~WAS_REAL)

            errMsg=DAStudio.message('sl_sta:editor:changeSignalType');
            msgTopics=Simulink.sta.EditorTopics();

            if IS_INTEGRATING
                baseMsg='staeditor';
            else

                baseMsg='sta';
            end

            fullChannel=sprintf('/%s%s/%s',baseMsg,...
            appInstanceID,...
            msgTopics.DIAGNOSTICS_DLG);
            slwebwidgets.errordlgweb(fullChannel,...
            'sl_sta_general:common:Error',...
            errMsg);
            workingID=[];
            return;
        end

    catch ME

        returnStruct.errorMessage=ME.message;
        return;
    end



    eng.getSignalMetaData(sigID,'Dimensions');


    aFactory=starepository.repositorysignal.Factory;

    IS_FCN_CALL_UPDATE=~isempty(strfind(repoUtil.getMetaDataByName(sigID,'dataformat'),'functioncall'));

    tmpParentID=repoUtil.getParent(sigID);



    if IS_FCN_CALL_UPDATE


        timeVals=[dataFromTable(:).signaltime]';
        fcnCallVal=[];
        [~,idxSort]=sort(timeVals);
        dataVals=dataVals(idxSort);
        timeVals=timeVals(idxSort);



        for kTime=1:length(timeVals)
            fcnCallVal=[fcnCallVal,repmat(timeVals(kTime),1,dataVals(kTime))];
        end

        varIn=fcnCallVal';

    elseif(~isSignalComplex&&...
        strcmp(repoUtil.getMetaDataByName(sigID,'dataformat'),'simulinktimeseries'))||...
        (isSignalComplex&&...
        strcmp(repoUtil.getMetaDataByName(tmpParentID,'dataformat'),'simulinktimeseries'))


        concreteExtractor=aFactory.getSupportedExtractor(sigID);
        [repoSignal,~]=concreteExtractor.extractValue(sigID);
        varIn=Simulink.Timeseries;
        varIn.Name=repoSignal.Name;
        varIn.BlockPath=repoSignal.BlockPath;
        varIn.PortIndex=repoSignal.PortIndex;
        varIn.SignalName=repoSignal.SignalName;
        varIn.ParentName=repoSignal.ParentName;
        varIn.TimeInfo=repoSignal.TimeInfo;


        timeVals=[dataFromTable(:).signaltime]';
        [timeVals,idxSorted]=sort(timeVals);
        varIn.Time=timeVals;

        if isSignalComplex
            varIn.Data=dataVals(idxSorted).';
        else
            varIn.Data=dataVals(idxSorted)';
        end

    elseif(~isSignalComplex&&...
        contains(repoUtil.getMetaDataByName(sigID,'dataformat'),'sl_timetable'))||...
        (isSignalComplex&&...
        contains(repoUtil.getMetaDataByName(tmpParentID,'dataformat'),'sl_timetable'))

        timeVals=[dataFromTable(:).signaltime]';
        [Time_Vals,idxSorted]=sort(timeVals);


        if isSignalComplex
            metaSigID=repoUtil.getParent(sigID);
        else
            metaSigID=sigID;
        end

        timevalueUnits=repoUtil.getMetaDataByName(metaSigID,'TimeObjectClass');
        fcnH=str2func(timevalueUnits);
        Time_Vals=fcnH(Time_Vals);

        if isSignalComplex
            SL_TT_Data=dataVals(idxSorted).';
        else
            SL_TT_Data=dataVals(idxSorted)';
        end

        dimNames=repoUtil.getMetaDataByName(metaSigID,'DimensionNames');

        evalTimeVals(dimNames{1});

        VariableNames=repoUtil.getMetaDataByName(metaSigID,'VariableNames');
        VariableUnits=repoUtil.getMetaDataByName(metaSigID,'VariableUnits');

        evalCmd=sprintf('timetable(%s, SL_TT_Data, ''VariableNames'', VariableNames)',...
        dimNames{1});
        varIn=eval(evalCmd);
        varIn.Properties.VariableUnits=VariableUnits;
    else


        if isSignalComplex
            dataVals=dataVals.';
        else
            dataVals=dataVals';
        end

        timeVals=[dataFromTable(:).signaltime]';
        [timeVals,idxSorted]=sort(timeVals);

        varIn=timeseries(dataVals(idxSorted),...
        timeVals);

        if isSignalComplex
            tsNAME=repoUtil.getMetaDataByName(repoUtil.getParent(sigID),'TSName');
        else
            tsNAME=repoUtil.getMetaDataByName(sigID,'TSName');
        end

        varIn.Name=tsNAME;


        if strcmpi(interpMode,'ZeroOrderHold')||strcmp(dataType,'string')
            varIn.DataInfo.Interpolation=tsdata.interpolation('zoh');
        end



    end

    if~IS_FCN_CALL_UPDATE


        IS_DATA_TYPE_CHANGE=~strcmp(dataType,originalDataType);
    end



    parentID=eng.getSignalParent(sigID);

    if isSignalComplex
        sigNameToUse=eng.getSignalName(parentID);
    else
        sigNameToUse=sigName;
    end

    if~isSignalComplex&&contains(repoUtil.getMetaDataByName(sigID,'dataformat'),'loggedsignal')
        repositoryTS=starepository.repositorysignal.BlockData();
        varValue=createSimulinkSimulationDataSignal(repositoryTS,sigID);
        varValue.Values=varIn;
        varIn=varValue;

    elseif isSignalComplex&&contains(repoUtil.getMetaDataByName(parentID,'dataformat'),'loggedsignal')

        repositoryTS=starepository.repositorysignal.BlockData();
        varValue=createSimulinkSimulationDataSignal(repositoryTS,parentID);
        varValue.Values=varIn;
        varIn=varValue;

    end

    itemFactory=starepository.factory.createSignalItemFactory(sigNameToUse,varIn);

    item=itemFactory.createSignalItem;

    repoUtil=starepository.RepositoryUtility();



    fileToWriteUpdateTo=repoUtil.getMetaDataByName(sigID,'LastKnownFullFile');


    if parentID~=0


        if~isSignalComplex

            parentSignalName=eng.getSignalName(parentID);
            item.setParentName(parentSignalName);


        else
            GrandParentID=eng.getSignalParent(parentID);

            if GrandParentID~=0
                parentSignalName=eng.getSignalName(GrandParentID);

                item.setParentName(parentSignalName);

            end

        end





        fileToWriteUpdateTo=eng.getSignalMetaData(parentID,'LastKnownFullFile');
    end


    if isempty(fileToWriteUpdateTo)
        fileToWriteUpdateTo='';
    end



    if~isSignalComplex
        treeOrder=getMetaDataByName(repoUtil,sigID,'TreeOrder');
    else
        treeOrder=getMetaDataByName(repoUtil,parentID,'TreeOrder');
    end

    jsonStruct=eng.safeTransaction(@initRepository,{item},fileToWriteUpdateTo,treeOrder);

    for kChild=1:length(jsonStruct)
        jsonStruct{kChild}.TreeOrder=treeOrder;
        setMetaDataByName(repoUtil,jsonStruct{kChild}.ID,'TreeOrder',treeOrder);

        if isfield(jsonStruct{kChild},'ComplexID')
            setMetaDataByName(repoUtil,jsonStruct{kChild}.ComplexID,'TreeOrder',treeOrder);
        end
        treeOrder=treeOrder+1;
    end



    if parentID~=0

        if~isSignalComplex
            replaceChild(repoUtil,sigID,jsonStruct{1}.ID);
            jsonStruct{1}.ParentID=parentID;

            setMetaDataByName(repoUtil,jsonStruct{1}.ID,'ParentID',parentID);
        else

            if GrandParentID~=0
                replaceChild(repoUtil,parentID,jsonStruct{1}.ID);
                jsonStruct{1}.ParentID=GrandParentID;

                setMetaDataByName(repoUtil,jsonStruct{1}.ID,'ParentID',GrandParentID);
            end

        end

    end



    outdata.arrayOfListItems=jsonStruct;

    if~isSignalComplex
        outdata.editted_id=sigID;
    else
        childIds=getChildrenIds(repoUtil,parentID);
        outdata.editted_id=[parentID,childIds];
    end

    if IS_FCN_CALL_UPDATE||...
        IS_COMPLEXITY_CHANGE||...
IS_DATA_TYPE_CHANGE


        setMetaDataByName(repoUtil,jsonStruct{1}.ID,'IS_EDITED',1);
        oldestParent=repoUtil.getOldestRelative(jsonStruct{1}.ID);
        setMetaDataByName(repoUtil,oldestParent,'IS_EDITED',1);

    end


    msgTopics=Simulink.sta.EditorTopics();


    if IS_INTEGRATING
        fullChannel=sprintf('/staeditor%s/%s',appInstanceID,msgTopics.SIGNAL_EDIT);
        fullChannelSigUpdated=sprintf('/staeditor%s/%s',appInstanceID,msgTopics.ID_TO_REPORT);
    else
        fullChannel=sprintf('/sta%s/%s',appInstanceID,msgTopics.SIGNAL_EDIT);
        fullChannelSigUpdated=sprintf('/sta%s/%s',appInstanceID,msgTopics.ID_TO_REPORT);
    end
    message.publish(fullChannel,outdata);
    message.publish(fullChannelSigUpdated,sigID);




    msg.signaltime=Simulink.sta.tableview.makeJsonSafe([dataFromTable(:).signaltime]');

    if~isSignalComplex
        msg.signaldata=Simulink.sta.tableview.makeJsonSafe(dataVals');
    else
        msg.signaldata=Simulink.sta.tableview.makeJsonSafe(dataVals.');
    end

    msg.id=0:(length(dataVals)-1);
    msg.order=0:(length(dataVals)-1);
    tableTopics=Simulink.sta.tableview.TableViewTopics(appInstanceID);
    fullChannel=tableTopics.serverSideSignalUpdateTopic;
    message.publish(fullChannel,msg);

    workingID=jsonStruct{1}.ID;

    returnStruct.workingID=workingID;

end

function jsonStruct=initRepository(item,fileName,startingTreeOrder)

    runTimeRange.Start=[];
    runTimeRange.Stop=[];

    runID=Simulink.sdi.createRun;
    Simulink.sdi.internal.moveRunToApp(runID,'sta',true);

    parentSigID=0;

    jsonStruct={};


    if~isempty(item)


        for k=1:length(item)

            sigStruct=initializeRepository(item{k},fileName,k,runID,parentSigID,...
            runTimeRange);
            jsonStruct=[jsonStruct,sigStruct];

        end


        cellEmpty=cellfun(@isempty,jsonStruct);
        jsonStruct(cellEmpty)=[];
        repoUtil=starepository.RepositoryUtility();


        for kStruct=1:length(jsonStruct)

            jsonStruct{kStruct}.TreeOrder=startingTreeOrder+kStruct;



            setMetaDataByName(repoUtil,jsonStruct{kStruct}.ID,'TreeOrder',startingTreeOrder+kStruct);


            if ischar(jsonStruct{kStruct}.ParentID)&&strcmp(jsonStruct{kStruct}.ParentID,'input')

                exSource=sta.ExternalSource();
                exSource.SignalID=jsonStruct{kStruct}.ID;

                jsonStruct{kStruct}.ExternalSourceID=exSource.ID;
            end
        end

    end


end


function evalTimeVals(the_time_valsName)
    evalStr=sprintf('%s = Time_Vals;',the_time_valsName);
    evalin('caller',evalStr);
end

