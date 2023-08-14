function[inputPort,outputPort]=getDefaultPortsForSoftwareComponent(c)





    inputPort=[];
    outputPort=[];
    swArch=c.getArchitecture();
    ports=getPorts(swArch);
    for p=ports
        if isempty(inputPort)&&p.getPortAction==systemcomposer.architecture.model.core.PortAction.REQUEST
            inputPort=p;
        end
        if isempty(outputPort)&&p.getPortAction==systemcomposer.architecture.model.core.PortAction.PROVIDE
            outputPort=p;
        end
        if~isempty(inputPort)&&~isempty(outputPort)
            break
        end
    end
end
