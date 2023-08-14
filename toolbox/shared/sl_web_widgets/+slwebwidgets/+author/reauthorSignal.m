function outStruct=reauthorSignal(msg)




    outStruct.originalValueID=[];

    editorAppID=msg.appID;
    tableID=msg.tableID;


    msgTopics=Simulink.sta.EditorTopics();

    rootSigID=msg.rootSignalID;
    sigID=msg.signalID;

    if~isfield(msg,'modelName')||isempty(msg.modelName)
        [timeToUse,dataToUse]=slwebwidgets.author.getTimeAndDataFromExpression(...
        msg.timeEntry,msg.dataEntry);
    else
        [timeToUse,dataToUse]=slwebwidgets.author.getTimeAndDataFromExpression(...
        msg.timeEntry,msg.dataEntry,msg.modelName);
    end
    dataPreCast.Data=dataToUse;
    dataToUse=slwebwidgets.doSLCast(dataToUse,msg.dataTypeToUse);

    dataTypeOfDataExpression=class(dataToUse);
    IS_Enum=isenum(dataToUse);%#ok<NASGU>
    IS_STR=isa(dataToUse,'string');%#ok<NASGU>
    IS_FI=isfi(dataToUse);

    if IS_FI
        repoUtil=starepository.RepositoryUtility();
        rootMetaData=repoUtil.getMetaDataStructure(rootSigID);

        dataTypeOfDataExpression=msg.dataTypeToUse;
        compareDT=dataTypeOfDataExpression;
        compareDT(isspace(compareDT))=[];

        if~isfield(rootMetaData,'fiOverflowMode')
            rootMetaData.fiOverflowMode=dataToUse.OverflowMode;
            rootMetaData.fiRoundMode=dataToUse.RoundMode;
        end



        if strcmp(rootMetaData.DataType,compareDT)
            dataToUse.OverflowMode=rootMetaData.fiOverflowMode;
            dataToUse.RoundMode=rootMetaData.fiRoundMode;
        end
    end

    aFactory=starepository.repositorysignal.Factory;
    concreteExtractor=aFactory.getSupportedExtractor(rootSigID);


    repo=starepository.RepositoryUtility();
    signalNameToCopy=getVariableName(repo,rootSigID);
    simulinkSignal=getSimulinkSignalByID(repo,rootSigID);


    itemFactory=starepository.factory.createSignalItemFactory(signalNameToCopy,simulinkSignal);

    item=itemFactory.createSignalItem;

    eng=sdi.Repository(true);
    jsonStruct=eng.safeTransaction(@starepository.ioitem.initStreaming,{item},'junkfile',0);

    idToOriginalValues=jsonStruct{1}.ID;

    if isfield(jsonStruct{1},'ComplexID')
        idToOriginalValues=jsonStruct{1}.ComplexID;
    end
    outStruct.originalValueID=idToOriginalValues;





    cellOfNonScalars={'non_scalar','multidimtimeseries','ndimtimeseries'};
    metaDataValue=getMetaDataByName(concreteExtractor,rootSigID,'dataformat');

    signalType=getMetaDataByName(concreteExtractor,rootSigID,'SignalType');
    WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));%#ok<NASGU>

    repoUtil=starepository.RepositoryUtility;
    if contains(metaDataValue,cellOfNonScalars)

        if contains(metaDataValue,'multidimtimeseries')


            tsTmp=timeseries(dataToUse,timeToUse);%#ok<NASGU>

            childIDsInOrder=getChildrenIDsInSiblingOrder(repoUtil,rootSigID);

            cellOfIndicesStr=cell(1,length(childIDsInOrder));

            for kHeader=1:length(childIDsInOrder)
                strLabel=repoUtil.getSignalLabel(childIDsInOrder(kHeader));
                cellOfIndicesStr{kHeader}=strLabel(strfind(strLabel,'('):end);

                tmpData(:,kHeader)=eval(['tsTmp.Data',cellOfIndicesStr{kHeader}]);%#ok<AGROW>
            end

            dataToUse=tmpData;
        elseif contains(metaDataValue,'ndimtimeseries')



            tsTmp=timeseries(dataToUse,timeToUse);%#ok<NASGU>


            childIDsInOrder=getChildrenIds(repoUtil,rootSigID);

            cellOfIndicesStr=cell(1,length(childIDsInOrder));

            for kHeader=1:length(childIDsInOrder)
                strLabel=repoUtil.getMetaDataByName(childIDsInOrder(kHeader),'NDimIdxStr');
                cellOfIndicesStr{kHeader}=strLabel(strfind(strLabel,'('):end);
                tmpData(:,kHeader)=eval(['tsTmp.Data',cellOfIndicesStr{kHeader}]);%#ok<AGROW>
            end

            dataToUse=tmpData;
        end
    elseif contains(metaDataValue,'timeseries')
        tsTmp=timeseries(dataToUse,timeToUse);
        dataToUse=tsTmp.Data;
        timeToUse=tsTmp.Time;
    end

    dataToSet.Data=dataToUse;
    dataToSet.Time=timeToUse;

    if isa(dataToSet.Time,'duration')


        IS_YEARS=strcmp('y',dataToSet.Time.Format);
        IS_HOURS=strcmp('h',dataToSet.Time.Format);
        IS_MINUTES=strcmp('m',dataToSet.Time.Format);
        IS_SECONDS=strcmp('s',dataToSet.Time.Format);

        if IS_YEARS
            durationTypeString='years';
        elseif IS_HOURS
            durationTypeString='hours';
        elseif IS_MINUTES
            durationTypeString='minutes';
        elseif IS_SECONDS
            durationTypeString='seconds';
        else

            durationTypeString='seconds';
        end

        repoUtil.setMetaDataByName(rootSigID,'TimeObjectClass',durationTypeString);

        fcnH=str2func(durationTypeString);
        dataToSet.Time=double(fcnH(dataToSet.Time));
    end



    editSignalData(concreteExtractor,rootSigID,sigID,dataTypeOfDataExpression,dataToSet);



    authoringStruct.dataString=msg.dataEntry;
    authoringStruct.timeString=msg.timeEntry;
    authoringStruct.dataTypeToUse=msg.dataTypeToUse;

    repoUtil=starepository.RepositoryUtility();
    repoUtil.setMetaDataByName(rootSigID,'AuthoringInputs',authoringStruct)


    msg.signaltime=slwebwidgets.tableeditor.makeJsonSafe(dataToSet.Time);

    [NUM_POINTS,NUM_DATA_COL]=size(dataToSet.Data);
    msg.signaldata=cell(NUM_POINTS,NUM_DATA_COL);


    for kCol=1:NUM_DATA_COL

        msg.signaldata(:,kCol)=slwebwidgets.tableeditor.makeJsonSafe(dataToSet.Data(:,kCol));

        if IS_FI
            theFiType=dataToSet.Data.numerictype;
            for kCell=1:length(msg.signaldata(:,kCol))

                errorMeta=slwebwidgets.AuthorUtility.quantizeRWValues(dataPreCast.Data(kCell,kCol),theFiType,rootMetaData.fiOverflowMode,rootMetaData.fiRoundMode);
                msg.signaldata{kCell,kCol}=slwebwidgets.tableeditor.messagemanager.MessageManager.makeFiDataTableStruct(double(dataPreCast.Data(kCell,kCol)),dataToSet.Data(kCell,kCol),errorMeta);
            end
        end
    end

    msg.isdataarray=false;

    for k=1:length(msg.signaltime)
        msgOut.signaldatavalues{k}={msg.signaltime{k},msg.signaldata{k,:}};
    end


    tableTopics=slwebwidgets.tableeditor.TableViewTopics(editorAppID,tableID);
    fullChannel=tableTopics.serverSideSignalUpdateTopic;
    message.publish(fullChannel,msgOut);



    fullChannel=sprintf('/staeditor%s/%s',editorAppID,msgTopics.SIGNAL_EDIT);%#ok<NASGU>
    fullChannelSigUpdated=sprintf('/staeditor%s/%s',editorAppID,msgTopics.ID_TO_REPORT);
    message.publish(fullChannelSigUpdated,sigID);
















    fullChannel=sprintf('/staeditor%s/%s',editorAppID,'force_axes_redraw');


    replotIDs=getPlottableSignalIDs(concreteExtractor,rootSigID);

    for k=1:length(replotIDs)
        msgOutRedraw.signalID=replotIDs(k);
        message.publish(fullChannel,msgOutRedraw);
    end

end
