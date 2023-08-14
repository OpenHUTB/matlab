function ports=getAllSLOutputPorts(this,hC)%#ok








    ports=[];
    for ii=1:length(hC.SLOutputPorts)
        ports=[ports,hC.SLOutputPorts(ii)];%#ok
    end


