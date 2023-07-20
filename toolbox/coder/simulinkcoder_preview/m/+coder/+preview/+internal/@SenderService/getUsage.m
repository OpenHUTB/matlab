function out=getUsage(obj)







    mode=obj.getProperty('DataCommunicationMethod');
    serviceFunction=obj.getFunctionName(obj.Entry.FunctionNamingRuleForValue);
    callableFunction=obj.getDefaultCallableFunctionName;
    dN=obj.IdentifierResolver.dN;
    if mode=="OutsideExecution"
        tooltip=message('SimulinkCoderApp:ui:SenderOutsideExecutionTooltip',...
        callableFunction,serviceFunction,dN).getString;
        body={
'...'
        [serviceFunction,'(...);']
'...'
        };
    elseif mode=="DuringExecution"
        tooltip=message('SimulinkCoderApp:ui:SenderDuringExecutionTooltip',...
        callableFunction,serviceFunction,dN).getString;
        body={
'DATATYPE tmp = ...'
'...'
        [serviceFunction,'(tmp);']
        };
    else

        body={'OUT = ...;'};
    end

    out=[
    obj.getUsageHeader...
    ,'<p>',message('SimulinkCoderApp:ui:SenderPseudocode').getString...
    ,obj.getCallableFunctionPreview(callableFunction,body,'BodyTooltip',tooltip);
    ];


