function spec=getCharacterizationSpec(~)





    spec=struct();




    param=characterization.ParamDesc();
    param.name='Gain';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'2','16','7','47'};
    param.regenerateModel=true;
    params=param;

    param=characterization.ParamDesc();
    param.name='DSPStyle';
    param.type=characterization.ParamDesc.HDL_PARAM;
    param.values={'none','on','off'};
    param.toolDepedentParam=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='Multiplication';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'Element-wise(K.*u)'};
    param.regenerateModel=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='ConstMultiplierOptimization';
    param.type=characterization.ParamDesc.HDL_PARAM;
    param.values={'auto'};
    param.toolDepedentParam=true;
    params(end+1)=param;







    port=characterization.PortDesc();
    port.port=characterization.PortDesc.REMAINING_PORTS;
    port.range={4,64,4};
    port.widthTemplate='fixdt(1, %d, 0)';
    ports=port;

    spec.ports=ports;
    spec.params=params;
    spec.widthSpec={1};

end
