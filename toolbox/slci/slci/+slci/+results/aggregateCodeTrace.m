

function codeTraceStatus=aggregateCodeTrace(datamgr,reportConfig)

    codeReader=datamgr.getReader('CODE');
    codeKeys=codeReader.getKeys();




    inspectedFiles=datamgr.getMetaData('InspectedCodeFiles');
    filesToTrace=inspectedFiles.filesToTrace;
    codeMap=slci.results.groupCode(codeKeys,filesToTrace,datamgr);


    allCodeObjects=values(codeMap);
    traceStatuses=reportConfig.getCodeTraceStatusList();
    traceStatusesToAgg={};

    countMap=slci.internal.ReportUtil.getTraceCounts(cat(1,allCodeObjects{:}),...
    traceStatuses);
    for k=1:numel(traceStatuses)
        thisStatus=traceStatuses{k};
        if(countMap(thisStatus)>0)
            traceStatusesToAgg{end+1}=thisStatus;%#ok
        end
    end

    codeTraceStatus=reportConfig.getHeaviest(traceStatusesToAgg);
    codeTraceStatus=reportConfig.getTopTraceStatus(codeTraceStatus);

end
