function msg=publishTableUpdate(appInstanceID,dataInfo)




    dataToSet=dataInfo.dataToSet;

    isFixDT=dataInfo.isFixDT;

    tableID=dataInfo.tableID;

    if isFixDT
        numericTypeValue=dataInfo.numericTypeValue;
        rootMetaData=dataInfo.rootMetaData;
    end




    msgTopics=Simulink.sta.EditorTopics();

    fullChannelSigUpdated=sprintf('/staeditor%s/%s',appInstanceID,msgTopics.ID_TO_REPORT);
    message.publish(fullChannelSigUpdated,dataInfo.rootSigID);



    msg.signaltime=slwebwidgets.tableeditor.makeJsonSafe(dataToSet.Time);

    [NUM_POINTS,NUM_DATA_COL]=size(dataToSet.Data);
    msg.signaldata=cell(NUM_POINTS,NUM_DATA_COL);


    for kCol=1:NUM_DATA_COL

        msg.signaldata(:,kCol)=slwebwidgets.tableeditor.makeJsonSafe(dataToSet.Data(:,kCol));

        if isFixDT
            theFiType=numericTypeValue;
            for kCell=1:length(msg.signaldata(:,kCol))

                errorMeta=slwebwidgets.AuthorUtility.quantizeRWValues(dataToSet.Data(kCell,kCol),theFiType,rootMetaData.fiOverflowMode,rootMetaData.fiRoundMode);
                msg.signaldata{kCell,kCol}=slwebwidgets.tableeditor.messagemanager.MessageManager.makeFiDataTableStruct(double(dataToSet.Data(kCell,kCol)),errorMeta.fiValue,errorMeta);
            end
        end
    end

    msg.isdataarray=false;

    for k=1:length(msg.signaltime)

        msgOut.signaldatavalues{k}={msg.signaltime{k},msg.signaldata{k,:}};
    end

    tableTopics=slwebwidgets.tableeditor.TableViewTopics(appInstanceID,tableID);
    fullChannel=tableTopics.serverSideSignalUpdateTopic;
    message.publish(fullChannel,msgOut);
