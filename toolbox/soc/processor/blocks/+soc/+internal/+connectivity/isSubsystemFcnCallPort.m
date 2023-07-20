function res=isSubsystemFcnCallPort(sys,portNum)




    import soc.internal.connectivity.*

    triggerPort=getSystemTriggerPort(sys);
    if~isempty(triggerPort)
        res=true;
    else
        inputPorts=getSystemInputPorts(sys);
        res=isequal(get_param(inputPorts(portNum),...
        'OutputFunctionCall'),'off');
    end
end