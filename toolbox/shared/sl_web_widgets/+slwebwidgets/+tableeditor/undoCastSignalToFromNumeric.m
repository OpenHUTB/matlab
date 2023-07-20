function undoCastSignalToFromNumeric(signalInfo)











    dataTypeToSet=signalInfo.dataTypeToSet;

    rootSignalID=signalInfo.rootSignalID;
    idToOriginalValues=signalInfo.idToOriginalValues(1);


    appInstanceID=signalInfo.appInstanceID;

    aFactory=starepository.repositorysignal.Factory;
    concreteExtractor=aFactory.getSupportedExtractor(rootSignalID);

    repoUtil=starepository.RepositoryUtility();
    signalType=getMetaDataByName(repoUtil,rootSignalID,'SignalType');
    WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));


    castNoBackUp(concreteExtractor,rootSignalID,WAS_REAL,dataTypeToSet);

    setMetaDataByName(repoUtil,rootSignalID,'DataType',dataTypeToSet);

    if contains(dataTypeToSet,'fixdt')

        aDataVal=getADataValue(concreteExtractor,rootSignalID);


        metaData_struct=starepository.ioitem.DataDump.appendFiDataToMetaDataStruct(aDataVal,struct);

        metaName=fieldnames(metaData_struct);


        for kField=1:length(metaName)
            setMetaDataByName(repoUtil,rootSignalID,metaName{kField},metaData_struct.(metaName{kField}));
        end
    else
        setMetaDataByName(repoUtil,rootSignalID,'isFixDT',false);
    end


    dataInfo.rootSigID=rootSignalID;
    dataInfo.idOfDataToRestore=idToOriginalValues;
    dataInfo.appInstanceID=appInstanceID;
    dataInfo.tableID=signalInfo.tableID;
    slwebwidgets.tableeditor.restoreSignalDataByID(dataInfo);


