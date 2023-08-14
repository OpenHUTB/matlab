function spec=HDLCounterCharSpec(compName)





    spec=struct();









    spec.dataType='fixdt';

    param=characterization.ParamDesc();
    param.name='CountType';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'Count limited','Free running'};
    param.regenerateModel=true;
    params=param;

    param=characterization.ParamDesc();
    param.name='CountResetPort';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'on','off'};
    param.regenerateModel=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='CountLoadPort';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'on','off'};
    param.regenerateModel=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='CountEnbPort';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'on','off'};
    param.regenerateModel=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='CountDirPort';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'on','off'};
    param.regenerateModel=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='CountStep';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.doNotOutput=true;
    param.values={'5'};
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='CountWordLen';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'4','8','10','12','16','20','24','28','32','48'};
    param.doNotOutput=true;
    params(end+1)=param;

    port=characterization.PortDesc();
    port.port=characterization.PortDesc.REMAINING_PORTS;
    port.range={1,1,1};
    port.widthTemplate='boolean';
    ports=port;

    spec.ports=ports;
    spec.params=params;
    spec.widthSpec={1};

end
