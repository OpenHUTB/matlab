function spec=getCharacterizationSpec(~)





    spec=struct();




    param=characterization.ParamDesc();
    param.name='Operator';
    param.values={'AND','OR','NAND','NOR','XOR','NXOR','NOT'};
    param.regenerateModel=true;
    params=param;

    param=characterization.ParamDesc();
    param.name='Inputs';
    param.values={'2','4','8','12','16','32','64','128'};
    param.regenerateModel=true;
    param.doNotOutput=true;
    params(end+1)=param;




    port=characterization.PortDesc();
    port.port=characterization.PortDesc.REMAINING_PORTS;
    port.range={1,1,1};
    port.widthTemplate='boolean';
    ports=port;

    spec.params=params;
    spec.ports=ports;
    spec.widthSpec={1};

end


