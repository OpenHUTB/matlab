function ports=getAllPirOutputPorts(this,hC)%#ok








    ports=[];
    for ii=1:length(hC.PirOutputPorts)
        ports=[ports,hC.PirOutputPorts(ii)];%#ok
    end


