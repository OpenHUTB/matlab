function EvaluateBlockForAnimationUpdate(blockHandle)








    chartId=sfprivate('block2chart',blockHandle);
    if isempty(chartId)
        return
    end
    machineId=sf('get',chartId,'chart.machine');
    mexFunctionName=sf('get',machineId,'machine.debug.runningMexFunction');
    if isempty(mexFunctionName)
        return
    end
    try
        feval(mexFunctionName,'sf_debug_api','active_instance',machineId,chartId,blockHandle);
    catch ME
        disp(ME.message);
    end
    instanceObj=get_param(blockHandle,'Object');
    currentHighlights=getappdata(instanceObj,'StateflowHighlightList');
    sf('Highlight',chartId,currentHighlights,blockHandle);
end
