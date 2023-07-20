function spec=RateTransitionCharSpec(compName)





    spec=struct();









    spec.dataType='fixdt';

    param=characterization.ParamDesc();
    param.name='OutPortSampleTimeOpt';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'Specify'};
    param.doNotOutput=true;
    params=param;

    param=characterization.ParamDesc();
    param.name='Integrity';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'on'};
    param.doNotOutput=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='Deterministic';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'on'};
    param.doNotOutput=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='OutPortSampleTime';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'5','10','20'};
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
