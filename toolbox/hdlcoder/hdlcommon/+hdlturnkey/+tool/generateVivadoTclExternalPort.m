function generateVivadoTclExternalPort(fid,portName,portWidth,portType,pinName,ipInstance)



    if(nargin<5)
        pinName=portName;
    end


    if(nargin<6)
        ipInstance='$HDLCODERIPINST';
    end


    switch portType
    case hdlturnkey.IOType.IN
        dirStr='-dir I';
    case hdlturnkey.IOType.OUT
        dirStr='-dir O';
    case hdlturnkey.IOType.INOUT
        dirStr='-dir IO';
    end

    if portWidth==1
        vecStr='-from 0 -to 0';
    else
        vecStr=sprintf('-from %d -to 0',portWidth-1);
    end


    fprintf(fid,'create_bd_port %s %s %s\n',...
    dirStr,vecStr,pinName);
    fprintf(fid,'connect_bd_net [get_bd_ports %s] [get_bd_pins %s/%s]\n',...
    pinName,ipInstance,portName);




end

