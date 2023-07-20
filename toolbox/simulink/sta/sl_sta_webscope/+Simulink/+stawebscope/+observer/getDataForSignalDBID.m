function dataPublished=getDataForSignalDBID(clientParams)








    dataPublished=false;

    DataValues=extractDataFromRepository(clientParams);

    if~clientParams.fitToViewNeeded
        DataValues=thinData(DataValues,clientParams);
    end

    if isempty(DataValues.Data)
        return;
    end

    if length(DataValues.Data)==1
        DataValues.Time={DataValues.Time};
    end

    processedData=processData(DataValues,clientParams);

    publishData(processedData,clientParams);

    dataPublished=true;

end


function DataValues=extractDataFromRepository(clientParams)


    DataValues=Simulink.sdi.getSignal(clientParams.dbid).DataValues;

end

function DataValues=thinData(DataValues,clientParams)


    clientSettings=clientParams.clientSettings;
    tStart=clientSettings.startTime;
    tEnd=clientSettings.endTime;
    diff=tEnd-tStart;

    if isfinite(diff)
        tStart=tStart-diff;
        tEnd=tEnd+diff;
    end

    tRange=DataValues.Time>=tStart&DataValues.Time<=tEnd;

    DataValues.Time=DataValues.Time(tRange);
    DataValues.Data=DataValues.Data(tRange);

end

function processedData=processData(DataValues,clientParams)



    signals.data=DataValues.Data;
    signals.time=DataValues.Time;
    signals.dbid=sprintf('db%d',clientParams.dbid);
    signals.id=sprintf('db%d',clientParams.dbid);
    sig={signals};
    processedData=struct('matrixData',false,'signals',{sig});

end

function publishData(jsonData,clientParams)


    clientId=clientParams.clientId;
    channel=['/webscope',clientId];
    eventData=struct('action',['updateData',clientId],'params',jsonData);
    message.publish(channel,eventData);

end