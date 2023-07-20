


function y=isCtrlPort(oIp)
    ctrlPort={'enable','Enable','trigger','Trigger',...
    'reset','Reset','ifaction'};
    portType=oIp.PortType;
    y=ismember(portType,ctrlPort);
end
