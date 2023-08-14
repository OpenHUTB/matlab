function regionData=getRegionData(editorId)
    data=matlab.internal.editor.RegionDataInfo;
    responseListener=message.subscribe(...
    ['/embeddedOutputs/getRegionsDataResponse/',editorId],...
    @(response)handleRegionsDataResponse(data,response));
    cleanupObj.Listener=onCleanup(@()message.unsubscribe(responseListener));



    t=timer('StartDelay',180,'TimerFcn',@(~,~)handleTimeout(data));
    cleanupObj.Timer=onCleanup(@()cleanUpTimer(t));
    start(t);

    message.publish(['/embeddedOutputs/getRegionsDataRequest/',editorId],[]);


    waitfor(data,'RegionData');

    if data.HasError
        error(data.ErrorMessage);
    end

    regionData=data.RegionData;
end

function handleRegionsDataResponse(data,response)
    if response.status
        data.setRegionData(response.regionsData);
    else

        data.setError(response.exception);
        data.setRegionData('[]');
    end
end

function handleTimeout(data)
    response.status=false;
    response.exception='Get regions request/response timed out.';
    handleRegionsDataResponse(data,response);
end

function cleanUpTimer(t)
    stop(t);
    delete(t);
end