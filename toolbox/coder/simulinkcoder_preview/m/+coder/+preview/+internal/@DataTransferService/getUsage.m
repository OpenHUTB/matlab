function out=getUsage(obj)







    mode=obj.Entry.DataCommunicationMethod;

    receiverFunction=obj.getReceiverFunctionName;
    senderFunction=obj.getSenderFunctionName;
    callableFunction=obj.getDefaultCallableFunctionName;

    if mode=="OutsideExecution"
        tooltip1=message('SimulinkCoderApp:ui:DataTransferReceiverOutsideExecutionTooltip',...
        callableFunction,receiverFunction,'IN').getString;
        tooltip2=message('SimulinkCoderApp:ui:DataTransferSenderOutsideExecutionTooltip',...
        callableFunction,senderFunction,'OUT').getString;
        body={
        sprintf('<span title="%s">...',tooltip1)
        ['... = ',receiverFunction,'() ... ;</span>']
'...'
        sprintf('<span title="%s">%s(...);',tooltip2,senderFunction)
'...</span>'
        };
    elseif mode=="DuringExecution"
        tooltip1=message('SimulinkCoderApp:ui:DataTransferReceiverDuringExecutionTooltip',...
        callableFunction,receiverFunction,'IN').getString;
        tooltip2=message('SimulinkCoderApp:ui:DataTransferSenderDuringExecutionTooltip',...
        callableFunction,senderFunction,'OUT').getString;
        body={
        sprintf('<span title="%s">DATATYPE tmp0 = %s();',tooltip1,receiverFunction)
'...'
'... = tmp0 ... ;</span>'
'...'
        sprintf('<span title="%s">DATATYPE tmp1 = ...;',tooltip2)
'...'
        [senderFunction,'(tmp1);</span>']
        };
    end

    out=[
    obj.getUsageHeader...
    ,'<p>',message('SimulinkCoderApp:ui:DataTransferPseudocode').getString...
    ,obj.getCallableFunctionPreview(callableFunction,body);
    ];


