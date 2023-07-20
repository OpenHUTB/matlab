function spec=TappedDelayCharSpec(compName)





    spec=struct();









    spec.dataType='fixdt';

    port=characterization.PortDesc();
    port.port={1};
    port.range={4,4,4};
    port.widthTemplate='fixdt(1, %d, 0)';
    ports=port;

    spec.params={};
    spec.ports=ports;
    spec.widthSpec={1};

end
