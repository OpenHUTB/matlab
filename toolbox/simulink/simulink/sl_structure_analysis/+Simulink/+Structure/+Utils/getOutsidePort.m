



function portOutside=getOutsidePort(portInside)

    import Simulink.Structure.Utils.*


    portOutside=portInside;

    ipO=get_param(portInside,'Object');
    ipType=ipO.PortType;

    owner=get_param(portInside,'Parent');
    ownerObj=get_param(owner,'Object');
    portNumber=str2double(ownerObj.Port);
    ownerSub=get_param(owner,'Parent');

    so=get_param(ownerSub,'Object');



    if strcmp(so.type,'block_diagram')
        return;
    end

    if isSubsystemVirtual(so)||isSubsystemNonVirtual(so)

        ports=so.PortHandles;

        if isInputOrControlPort(ipO)
            portOutside=ports.Outport;
        elseif strcmp(ipType,'Outport')
            portOutside=getAllInportHandles(ports);
        else
            portOutside=portInside;
            return;
        end

        portOutside=portOutside(portNumber);

    end

end