function spec=RecipSqrtNewtonSingleRateCharSpec(compName)





    spec=struct();









    spec.dataType='fixdt';

    param=characterization.ParamDesc();
    param.name='Iterations';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'};
    params=param;

    port=characterization.PortDesc();
    port.port={1};
    port.range={4,48,4};
    port.widthTemplate='fixdt(0,%d,0)';
    ports=port;

    spec.ports=ports;
    spec.params=params;
    spec.widthSpec={1};

end
