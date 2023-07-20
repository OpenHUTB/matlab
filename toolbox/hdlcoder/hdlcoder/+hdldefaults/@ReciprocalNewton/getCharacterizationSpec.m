function spec=getCharacterizationSpec(~)





    spec=struct();




    param=characterization.ParamDesc();
    param.name='NumberOfIterations';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'3','4','5','6'};
    param.toolDepedentParam=false;
    params=param;




    port=characterization.PortDesc();
    port.port={1};
    port.range={4,64,4};
    port.widthTemplate='fixdt(1, %d, 0)';
    ports=port;

    spec.params=params;
    spec.ports=ports;
    spec.widthSpec={1};

end
