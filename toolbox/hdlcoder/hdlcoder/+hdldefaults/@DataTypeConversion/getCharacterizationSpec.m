function spec=getCharacterizationSpec(~)





    spec=struct();




    param=characterization.ParamDesc();
    param.name='RndMeth';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'};
    param.toolDepedentParam=false;
    params=param;

    param=characterization.ParamDesc();
    param.name='SaturateOnIntegerOverflow';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'on','off'};
    param.toolDepedentParam=false;
    params(end+1)=param;




    port=characterization.PortDesc();
    port.port={1};
    port.range={4,64,4};
    port.widthTemplate='fixdt(1, %d, 0)';
    ports=port;

    spec.params=params;
    spec.ports=ports;
    spec.widthSpec={1};

end
