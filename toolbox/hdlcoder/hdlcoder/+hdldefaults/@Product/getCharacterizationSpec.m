function spec=getCharacterizationSpec(~)





    spec=struct();




    param=characterization.ParamDesc();
    param.name='DSPStyle';
    param.type=characterization.ParamDesc.HDL_PARAM;
    param.values={'none','on','off'};
    param.toolDepedentParam=true;
    params=param;




    port=characterization.PortDesc();
    port.port={1,2};
    port.range={2,64,2};
    port.widthTemplate='fixdt(1, %d, 0)';
    ports=port;

    spec.params=params;
    spec.ports=ports;
    spec.widthSpec={1,2};

end
