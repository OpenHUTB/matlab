function setTimeoutTo(clientPortBlock,timeoutValue)



    if isempty(timeoutValue)

        timeoutValue='1';
    end

    model=get_param(clientPortBlock,'Parent');
    mapObj=autosar.api.getSimulinkMapping(model);

    portName=get_param(clientPortBlock,'PortName');
    methodName=get_param(clientPortBlock,'Element');
    mapObj.mapFunctionElementCall([portName,'.',methodName],timeoutValue);
