function spec=getCharacterizationSpec(~)





    spec=struct();




    port=characterization.PortDesc();
    port.port=characterization.PortDesc.REMAINING_PORTS;
    port.range={1,1,1};
    port.widthTemplate='boolean';
    ports=port;

    spec.ports=ports;
    spec.params={};
    spec.widthSpec={1};

end
