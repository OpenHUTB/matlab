function spec=MultiPortSwitchCharSpec(compName)





    spec=struct();










    spec.dataType='fixdt';

    param=characterization.ParamDesc();
    param.name='Inputs';
    param.values={'2','4','6','8','10','12','14','16','20','24','28','32','40','48','64','72','124','128'};
    param.doNotOutput=true;
    param.regenerateModel=true;
    params=param;

    param=characterization.ParamDesc();
    param.name='DataPortForDefault';
    param.values={'Last data port'};
    param.doNotOutput=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='DataPortOrder';
    param.values={'Zero-based contiguous'};
    param.doNotOutput=true;
    params(end+1)=param;

    port=characterization.PortDesc();
    port.port={1};
    port.range={32,32,32};
    port.widthTemplate='fixdt(0, %d, 0)';
    ports=port;

    port=characterization.PortDesc();
    port.port={characterization.PortDesc.REMAINING_PORTS};
    port.range={32,32,32};
    port.widthTemplate='fixdt(0, %d, 0)';
    ports(end+1)=port;

    spec.params=params;
    spec.ports=ports;
    spec.widthSpec={1};

end
