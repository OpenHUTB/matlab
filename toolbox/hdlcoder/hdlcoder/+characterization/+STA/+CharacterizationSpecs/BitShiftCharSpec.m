function spec=BitShiftCharSpec(compName)





    spec=struct();









    spec.dataType='fixdt';

    param=characterization.ParamDesc();
    param.name='mode';
    param.values={'Shift Left Logical','Shift Right Logical','Shift Right Arithmetic'};
    params=param;

    param=characterization.ParamDesc();
    param.name='N';
    param.values={'1','2','4','8','12','16','24','32','48','64','72','124'};
    param.doNotOutput=true;
    params(end+1)=param;




    port=characterization.PortDesc();
    port.port={1};
    port.range={128,128,128};
    port.widthTemplate='fixdt(1, 128, 0)';
    ports=port;

    spec.params=params;
    spec.ports=ports;
    spec.widthSpec={1};

end
