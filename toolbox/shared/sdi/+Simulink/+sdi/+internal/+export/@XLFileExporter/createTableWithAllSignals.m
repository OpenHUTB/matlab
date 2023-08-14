function[data,metaData,numMDRows]=createTableWithAllSignals(this,eng,runObj,opts)





    [dtRow,unitsRow,interpRow,bpathRow,portRow]=this.initializeMetadataRows(opts);
    sigIDs=eng.sigRepository.getAllSignalIDs(runObj.id,'leaf');
    sigIDs=this.groupSigIDSBasedOnHierarchy(eng,sigIDs);
    [namesRow,mdRows]=this.getSignalNamesAndMetadaRows(...
    eng,runObj,sigIDs,dtRow,unitsRow,...
    interpRow,bpathRow,portRow);




    this.verifyXLColLimit(length(namesRow));
    [metaData,numMDRows]=this.createMetadataTable(namesRow,mdRows);
    data=this.createTable(eng,sigIDs,numMDRows);
end
