function spec=getCharacterizationSpec(~)





    spec=struct();





    port=characterization.PortDesc();
    port.port=characterization.PortDesc.REMAINING_PORTS;
    port.range={4,64,4};
    port.widthTemplate='fixdt(0, %d, 0)';
    ports=port;

    spec.ports=ports;
    spec.params={};
    spec.widthSpec={1};

end
