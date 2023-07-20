




function details=prepareTraceSummary(countMap,traceStatuses,reportConfig)


    numStatuses=numel(traceStatuses);
    details(numStatuses)=struct('STATUS',[],'COUNT',[]);
    for k=1:numStatuses
        status=traceStatuses{k};
        details(k).STATUS.CONTENT=reportConfig.getStatusMessage(status);
        details(k).STATUS.ATTRIBUTES='UNKNOWN';

        if countMap(status)>0
            details(k).COUNT.ATTRIBUTES=status;
        else
            details(k).COUNT.ATTRIBUTES='UNKNOWN';
        end
        details(k).COUNT.CONTENT=num2str(countMap(status));
    end
end
