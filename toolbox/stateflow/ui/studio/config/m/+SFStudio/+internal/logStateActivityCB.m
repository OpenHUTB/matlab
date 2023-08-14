function logStateActivityCB(cbinfo,varargin)
    stateH=cbinfo.getSelection();
    oldVal=stateH(1).LoggingInfo.DataLogging;

    for eachStateH=stateH'
        eachStateH.LoggingInfo.DataLogging=~oldVal;
        chartId=eachStateH.Chart.Id;
        blockH=sfprivate('chart2block',chartId);
        sfprivate('toggle_streaming_for_object',blockH,eachStateH.Id,eachStateH.LoggingInfo.DataLogging,'Self');
    end
end
