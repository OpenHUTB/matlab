function ports=getAllPirInputPorts(this,hC)%#ok








    ports=[];
    for ii=1:length(hC.PirInputPorts)
        ports=[ports,hC.PirInputPorts(ii)];%#ok
    end


