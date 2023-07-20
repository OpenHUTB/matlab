function bool=isChartPortIndexMessageType(blockPath,chartPortIndex)



    chartId=sfprivate('block2chart',get_param(blockPath,'Handle'));
    chartH=sf('IdToHandle',chartId);
    msgPort=chartH.find('-isa','Stateflow.Message','Scope','Output');
    msgPortIndexes=arrayfun(@(msg)msg.Port,msgPort);
    bool=ismember(chartPortIndex,msgPortIndexes);
end
