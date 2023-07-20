function v=validatePortDatatypes(this,hC)




















    ports=[];
    for ii=1:length(hC.SLInputPorts)
        if(ii~=2)
            ports=[ports,hC.SLInputPorts(ii)];%#ok
        end
    end


    ports=[ports,this.getAllSLOutputPorts(hC)];


    v=this.baseValidatePortDatatypes(ports);


