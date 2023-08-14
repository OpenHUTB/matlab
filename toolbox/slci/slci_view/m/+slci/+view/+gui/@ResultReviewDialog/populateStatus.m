



function populateStatus(obj)




    conf=slci.toolstrip.util.getConfiguration(obj.getStudio);


    dm=conf.getDataManager();
    if isempty(dm)
        return;
    end


    obj.fStatus='';
    resultsReader=dm.getReader('RESULTS');
    reportConfig=slci.internal.ReportConfig;
    if resultsReader.hasObject('Status')
        obj.fStatus=reportConfig.getStatusMessage(resultsReader.getObject('Status'));
    else
        obj.fStatus='Not Available';
    end


    obj.fCodeStatus=aggregateStatus(obj.fCodeSliceData);


    blockKeys=keys(obj.fBlockData);
    blockData=[];
    if~isempty(blockKeys)
        blockData=values(obj.fBlockData);
    end
    obj.fBlockStatus=aggregateStatus(blockData);


    obj.fInterfaceStatus=aggregateStatus(obj.fInterfaceData);



    obj.fTempVarStatus=aggregateStatus(obj.fTempVarData);


    obj.fUtilFuncStatus=aggregateStatus(obj.fUtilFuncData);

end


function status=aggregateStatus(data)

    passedStatusCount=0;
    failedStatusCount=0;
    warningStatusCount=0;
    justifiedStatusCount=0;

    for i=1:numel(data)









        if isfield(data{i},'parent')&&isempty(data{i}.parent)
            continue;
        end

        switch data{i}.status
        case 'VERIFIED'
            passedStatusCount=passedStatusCount+1;
        case{'FAILED_TO_VERIFY','UNEXPECTEDDEF'}
            failedStatusCount=failedStatusCount+1;
        case{'UNABLE_TO_PROCESS','PARTIALLY_PROCESSED','WAW','MANUAL'}
            warningStatusCount=warningStatusCount+1;
        case 'JUSTIFIED'
            justifiedStatusCount=justifiedStatusCount+1;
        otherwise
        end
    end

    status.passedStatusCount=passedStatusCount;
    status.failedStatusCount=failedStatusCount;
    status.warningStatusCount=warningStatusCount;
    status.justifiedStatusCount=justifiedStatusCount;

end