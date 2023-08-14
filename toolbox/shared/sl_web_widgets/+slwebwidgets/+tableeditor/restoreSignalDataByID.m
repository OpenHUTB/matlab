function restoreSignalDataByID(dataInfo)











    rootSigID=dataInfo.rootSigID;
    idOfDataToRestore=dataInfo.idOfDataToRestore;

    appInstanceID=dataInfo.appInstanceID;

    aFactory=starepository.repositorysignal.Factory;
    concreteExtractor=aFactory.getSupportedExtractor(rootSigID);

    if isfield(dataInfo,'dataTypetoRestore')

        repoUtil=starepository.RepositoryUtility();
        signalType=getMetaDataByName(repoUtil,rootSigID,'SignalType');
        WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));

        [~,~]=cast(concreteExtractor,rootSigID,WAS_REAL,dataInfo.dataTypetoRestore);
    end


    setDataByID(concreteExtractor,rootSigID,idOfDataToRestore);

    dataInfo.dataToSet=getDataForSetByID(concreteExtractor,rootSigID);

    aValue=dataInfo.dataToSet.Data(1);
    dataInfo.isFixDT=isfi(aValue);

    if dataInfo.isFixDT

        dataInfo.numericTypeValue=aValue.numerictype;
        dataInfo.rootMetaData.fiOverflowMode=getMetaDataByName(concreteExtractor,rootSigID,'fiOverflowMode');
        dataInfo.rootMetaData.fiRoundMode=getMetaDataByName(concreteExtractor,rootSigID,'fiRoundMode');
    end

    slwebwidgets.tableeditor.publishTableUpdate(appInstanceID,dataInfo);


    fullChannel=sprintf('/staeditor%s/%s',appInstanceID,'item/propertyupdate');
    replotIDs=getIDsForPropertyUpdates(concreteExtractor,rootSigID);
    itemPropertyUpdates=cell(size(replotIDs));
    for k=1:length(replotIDs)
        itemPropertyUpdates{k}.id=replotIDs(k);
        itemPropertyUpdates{k}.propertyname='DataType';
        itemPropertyUpdates{k}.newValue=...
        getMetaDataByName(concreteExtractor,replotIDs(k),'DataType');
    end
    message.publish(fullChannel,itemPropertyUpdates);
