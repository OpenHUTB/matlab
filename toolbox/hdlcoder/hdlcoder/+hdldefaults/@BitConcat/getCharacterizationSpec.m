function spec=getCharacterizationSpec(~)





    spec=struct();




    param=characterization.ParamDesc();
    param.name='NumInputs';
    param.values={'2','4','8','12','16','24','32','48','64','72','124','128'};
    param.doNotOutput=true;
    param.regenerateModel=true;
    params=param;




    port=characterization.PortDesc();
    port.port={characterization.PortDesc.REMAINING_PORTS};
    port.range={32,32,32};
    port.widthTemplate='fixdt(0, %d, 0)';
    ports=port;

    spec.params=params;
    spec.ports=ports;
    spec.widthSpec={1};

end
