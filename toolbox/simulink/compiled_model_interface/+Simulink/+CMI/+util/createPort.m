function po=createPort(sess,hdl)
    pType=get_param(hdl,'PortType');
    if strcmp(pType,'inport')
        po=Simulink.CMI.InPort(sess,hdl);
    elseif strcmp(pType,'outport')
        po=Simulink.CMI.OutPort(sess,hdl);
    elseif strcmp(pType,'trigger')
        po=Simulink.CMI.TriggerPort(sess,hdl);
    elseif strcmp(pType,'enable')
        po=Simulink.CMI.EnablePort(sess,hdl);
    elseif strcmp(pType,'state')
        po=Simulink.CMI.StatePort(sess,hdl);
    elseif strcmp(pType,'ifaction')
        po=Simulink.CMI.IfActionPort(sess,hdl);
    else
        ME=MException('Simulink:CMI:UnknownPortType',...
        '%s is not known to CMI as a port type',pType);
        throw(ME);
    end
end
