


function y=isInputOrControlPort(oIp)
    PortType={'inport','Inport','enable',...
    'Enable','trigger','Trigger','reset','Reset','ifaction'};
    portType=oIp.PortType;
    y=ismember(portType,PortType);
end

