function v=validatePortDatatypes(this,hC)





















    ports=this.getAllSLInputPorts(hC);


    ports=[ports,this.getAllSLOutputPorts(hC)];


    v=this.baseValidatePortDatatypes(ports);


