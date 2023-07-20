function spec=UnitDelayResettableCharSpec(compName)





    spec=struct();









    spec.dataType='fixdt';

    port=characterization.PortDesc();
    port.port={1};
    port.range={4,128,4};
    port.widthTemplate='fixdt(1, %d, 0)';
    ports=port;

    port=characterization.PortDesc();
    port.port={2};
    port.range={1,1,1};
    port.widthTemplate='boolean';
    ports(end+1)=port;

    spec.params={};
    spec.ports=ports;
    spec.widthSpec={1};

end
