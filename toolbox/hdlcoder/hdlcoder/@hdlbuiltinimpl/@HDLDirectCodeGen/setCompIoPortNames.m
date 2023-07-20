function setCompIoPortNames(this,hC,HDLComp)





    component=HDLComp;
    iPort=component.InputPortNames;
    oPort=component.OutputPortNames;

    for i=1:hC.NumberOfPirInputPorts
        hC.setInputPortName(i-1,iPort{i});
    end
    for i=1:hC.NumberOfPirOutputPorts
        hC.setOutputPortName(i-1,oPort{i});
    end
