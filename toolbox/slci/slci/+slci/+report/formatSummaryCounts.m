





function countSummary=formatSummaryCounts(countMap,statuses,message,reportConfig)

    numStatuses=numel(statuses);
    countSummary(numStatuses)=struct('STATUS',[],'COUNT',[]);

    for k=1:numStatuses
        thisStatus=statuses{k};
        countSummary(k).STATUS.CONTENT=[message...
        ,reportConfig.getStatusMessage(thisStatus),' : '];
        countSummary(k).STATUS.ATTRIBUTES='UNKNOWN';

        count=countMap(thisStatus);
        countSummary(k).COUNT.CONTENT=num2str(count);
        if count>0
            countSummary(k).COUNT.ATTRIBUTES=thisStatus;
        else
            countSummary(k).COUNT.ATTRIBUTES='UNKNOWN';
        end
    end
end
