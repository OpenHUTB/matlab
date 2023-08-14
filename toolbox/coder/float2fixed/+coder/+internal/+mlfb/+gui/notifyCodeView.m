function notifyCodeView(chartId,eventType,eventData)



    assert(isempty(eventData)||isstruct(eventData),'eventData must be a struct');

    if~isempty(eventData)
        dataMap=shallowStructToMap(eventData);
    else
        dataMap=java.util.Collections.emptyMap();
    end

    emlcprivate('mlfbPublishJavaMessage',...
    chartId,...
    com.mathworks.toolbox.coder.mlfb.FunctionBlockConstants.BACKEND_PUSH_TOPIC,...
    true,...
    eventType,...
    dataMap);
end

function dataMap=shallowStructToMap(dataStruct)
    dataFields=fields(dataStruct);
    dataMap=java.util.HashMap(ceil(numel(dataFields)/0.75));

    for i=1:numel(dataFields)
        fieldName=dataFields{i};

        try
            dataMap.put(fieldName,dataStruct.(fieldName));
        catch
            error('Error constructing Java data map caused by field ''%s''',fieldName);
        end
    end
end