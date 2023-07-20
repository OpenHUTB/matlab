function ports=gatherinputoutputports(this,hC)%#ok<INUSL>








    ports=[];


    for ii=1:length(hC.SLInputPorts)
        ports=[ports,hC.SLInputPorts(ii)];%#ok<AGROW>
    end

    for ii=1:length(hC.SLOutputPorts)
        ports=[ports,hC.SLOutputPorts(ii)];%#ok<AGROW>
    end


