function newJsonStruct=replaceSignalServerSideByID(sigID,idToReplaceWith,appInstanceID,tableID)




    aFactory=starepository.repositorysignal.Factory;
    concreteExtractor=aFactory.getSupportedExtractor(idToReplaceWith);

    newJsonStruct=concreteExtractor.jsonStructFromID(idToReplaceWith);


    dataInfo.rootSigID=newJsonStruct{1}.ID;
    dataValues=getDataForSetByID(concreteExtractor,dataInfo.rootSigID);
    dataInfo.dataToSet=dataValues;
    dataInfo.tableID=tableID;
    dataInfo.isFixDT=isfi(dataValues.Data);

    if dataInfo.isFixDT

        dataInfo.numericTypeValue=dataValues.Data.numerictype;
        dataInfo.rootMetaData.fiOverflowMode=getMetaDataByName(concreteExtractor,dataInfo.rootSigID,'fiOverflowMode');
        dataInfo.rootMetaData.fiRoundMode=getMetaDataByName(concreteExtractor,dataInfo.rootSigID,'fiRoundMode');
    end


    slwebwidgets.tableeditor.publishTableUpdate(appInstanceID,dataInfo);


    slwebwidgets.tableeditor.replaceSignalServerSide(sigID,newJsonStruct,appInstanceID);
