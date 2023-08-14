function spec=SwitchCharSpec(compName)





    spec=struct();









    spec.dataType='fixdt';

    param=characterization.ParamDesc();
    param.name='Criteria';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'u2 > Threshold','u2 >= Threshold','u2 ~= 0'};
    params=param;

    port=characterization.PortDesc();
    port.port={1,2,3};
    port.range={4,64,4};
    port.widthTemplate='fixdt(1, %d, 0)';
    ports=port;

    spec.ports=ports;
    spec.params=params;
    spec.widthSpec={2};

end
