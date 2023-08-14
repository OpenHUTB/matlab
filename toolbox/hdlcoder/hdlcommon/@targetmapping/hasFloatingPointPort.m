



function flag=hasFloatingPointPort(hC)

    ports=[hC.PirInputPorts;hC.PirOutputPorts];
    for i=1:length(ports)
        s=ports(i).Signal;
        if(targetmapping.isValidDataType(s.Type))
            flag=true;
            return;
        end
    end
    flag=false;

end