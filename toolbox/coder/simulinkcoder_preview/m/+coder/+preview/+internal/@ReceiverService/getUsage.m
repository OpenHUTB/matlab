function out=getUsage(obj)







    mode=obj.getProperty('DataCommunicationMethod');
    serviceFunction=obj.getFunctionName(obj.Entry.FunctionName);
    callableFunction=obj.getDefaultCallableFunctionName;
    dN=obj.IdentifierResolver.dN;
    if mode=="OutsideExecution"
        tooltip=message('SimulinkCoderApp:ui:ReceiverOutsideExecutionTooltip',...
        callableFunction,serviceFunction,dN).getString;
        body={
'...'
        ['... = ',serviceFunction,'() ... ;']
        };
    elseif mode=="DuringExecution"
        tooltip=message('SimulinkCoderApp:ui:ReceiverDuringExecutionTooltip',...
        callableFunction,serviceFunction,dN).getString;
        body={
        ['DATATYPE tmp = ',serviceFunction,'() ... ;']
'...'
'... = tmp ... ;'
        };
    end

    out=[
    obj.getUsageHeader...
    ,'<p>',message('SimulinkCoderApp:ui:ReceiverPseudocode').getString,...
    obj.getCallableFunctionPreview(callableFunction,body,'BodyTooltip',tooltip);
    ];


