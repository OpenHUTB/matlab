function populate(port,componentPort)

    port.specification=componentPort;
    port.setName(componentPort.getName);
    port.Action=componentPort.getPortAction;
end

