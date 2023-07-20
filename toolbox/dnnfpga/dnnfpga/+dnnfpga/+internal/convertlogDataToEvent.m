function events=convertlogDataToEvent(logData,numLogs)

    supportedEvents=dnnfpga.profiler.profilerUtils.resolveSupportedEventsForDAGNet;
    events=string.empty;
    for idx=1:numLogs
        for supportedEvent=supportedEvents
            if logData(idx)==2^supportedEvent.getBitRange
                events(end+1)=supportedEvent.getName;%#ok<AGROW>
            end
        end
    end
end
