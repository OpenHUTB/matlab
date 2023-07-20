function generateVivadoTclInternalConnection(fid,internalConnection,portName,ipInstance)




    if(nargin<4)
        ipInstance='$HDLCODERIPINST';
    end

    fprintf(fid,'connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins %s]] [get_bd_pins %s/%s] [get_bd_pins %s]\n',...
    internalConnection,ipInstance,portName,internalConnection);

end