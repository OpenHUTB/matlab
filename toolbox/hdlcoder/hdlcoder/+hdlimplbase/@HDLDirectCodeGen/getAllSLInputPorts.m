function ports=getAllSLInputPorts(this,hC)%#ok








    ports=[];
    for ii=1:length(hC.SLInputPorts)
        ports=[ports,hC.SLInputPorts(ii)];%#ok
    end


