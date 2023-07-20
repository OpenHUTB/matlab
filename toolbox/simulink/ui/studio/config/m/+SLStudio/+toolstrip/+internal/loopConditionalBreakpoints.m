function loopConditionalBreakpoints(conditionalPauseList,callback)
    for portIdx=1:length(conditionalPauseList)
        port=conditionalPauseList(portIdx);
        portData=port.data;

        conditionCounts=size(portData);

        if length(conditionCounts)<1,break;end

        conditionCount=conditionCounts(1);

        for conditionIdx=1:conditionCount
            callback(port,conditionIdx);
        end
    end
end