function[data,metaData,numMDRows]=createTableWithSelectedSignals(this,eng,runObj,sigIDs,opts)





    [dtRow,unitsRow,interpRow,bpathRow,portRow]=this.initializeMetadataRows(opts);


    repo=sdi.Repository(1);
    idsForRun=[];
    for sigIdx=1:length(sigIDs)
        currSigObj=Simulink.sdi.Signal(repo,sigIDs(sigIdx));
        if currSigObj.runID==runObj.id
            idsForRun(end+1)=sigIDs(sigIdx);%#ok
        end
    end

    [namesRow,mdRows]=this.getSignalNamesAndMetadaRows(...
    eng,runObj,idsForRun,dtRow,unitsRow,...
    interpRow,bpathRow,portRow);
    this.verifyXLColLimit(length(namesRow));

    partialSignal=struct();
    if isfield(opts,'startTime')&&isfield(opts,'endTime')
        partialSignal.startTime=opts.startTime;
        partialSignal.endTime=opts.endTime;
    end
    [metaData,numMDRows]=this.createMetadataTable(namesRow,mdRows);
    data=this.createTable(eng,idsForRun,numMDRows,partialSignal);
end
