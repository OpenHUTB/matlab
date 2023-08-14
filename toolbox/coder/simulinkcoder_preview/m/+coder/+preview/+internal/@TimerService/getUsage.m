function out=getUsage(obj)






    mode=obj.Entry.DataCommunicationMethod;
    serviceFunction=obj.getFunctionName(obj.Entry.FunctionClockTickFunctionName);
    callableFunction=obj.getDefaultCallableFunctionName;
    if mode=="OutsideExecution"
        tooltip=message('SimulinkCoderApp:ui:TimerServiceOutsideExecutionTooltip',...
        callableFunction,serviceFunction).getString;
        body={
'...'
        ['... = ',serviceFunction,'() ... ;']
        };
    elseif mode=="DuringExecution"
        variable='rtM-&gt;Timing.clockTick1';
        tooltip=message('SimulinkCoderApp:ui:TimerServiceDuringExecutionTooltip',...
        callableFunction,serviceFunction).getString;
        body={
        [variable,' = ',serviceFunction,'();']
'...'
        ['... = ',variable,' ... ;']
        };
    end

    out=[
    obj.getUsageHeader...
    ,'<p>',message('SimulinkCoderApp:ui:TimerServicePseudocode').getString...
    ,obj.getCallableFunctionPreview(callableFunction,body,'BodyTooltip',tooltip);
    ];


