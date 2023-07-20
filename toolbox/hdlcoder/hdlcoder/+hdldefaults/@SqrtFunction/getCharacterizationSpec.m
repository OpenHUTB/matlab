function spec=getCharacterizationSpec(~)





    spec=struct();




    param=characterization.ParamDesc();
    param.name='LatencyStrategy';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'max','zero'};
    param.regenerateModel=true;
    params=param;

    port=characterization.PortDesc();
    port.port={1};
    port.range={4,64,4};
    port.widthTemplate='fixdt(1, %d, 0)';
    ports=port;

    spec.params={};
    spec.ports=ports;
    spec.widthSpec={1};

end
