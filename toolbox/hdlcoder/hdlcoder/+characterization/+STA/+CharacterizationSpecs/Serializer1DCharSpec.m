function spec=Serializer1DCharSpec(~)





    spec=struct();









    spec.dataType='fixdt';

    param=characterization.ParamDesc();
    param.name='validIn';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'on','off'};
    param.regenerateModel=true;
    params=param;

    param=characterization.ParamDesc();
    param.name='validOut';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'on','off'};
    param.regenerateModel=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='startOut';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'on','off'};
    param.regenerateModel=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='IdleCycles';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'0'};
    param.doNotOutput=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='ratio';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'1','2','4','8','16','32','64','128'};
    param.doNotOutput=true;
    params(end+1)=param;

    port=characterization.PortDesc();
    port.port={1};
    port.range={1,1,1};
    port.widthTemplate='fixdt(0,16,0)';
    ports=port;

    spec.ports=ports;
    spec.params=params;
    spec.widthSpec={1};

end
