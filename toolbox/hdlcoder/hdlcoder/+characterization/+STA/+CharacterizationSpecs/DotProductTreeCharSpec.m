function spec=DotProductTreeCharSpec(compName)





    spec=struct();









    spec.dataType='fixdt';

    port=characterization.PortDesc();
    port.port={1,2};
    port.range={4,64,4};
    port.widthTemplate='fixdt(1, %d, 0)';
    ports=port;

    spec.params={};
    spec.ports=ports;
    spec.widthSpec={1,2};

end
