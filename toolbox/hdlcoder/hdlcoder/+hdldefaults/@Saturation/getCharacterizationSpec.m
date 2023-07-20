function spec=getCharacterizationSpec(~)





    spec=struct();




    param=characterization.ParamDesc();
    param.name='UpperLimit';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'1'};
    param.doNotOutput=true;
    params=param;

    param=characterization.ParamDesc();
    param.name='LowerLimit';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'0'};
    param.doNotOutput=true;
    params(end+1)=param;




    port=characterization.PortDesc();
    port.port={1};
    port.range={4,64,4};
    port.widthTemplate='fixdt(1,%d,0)';
    ports=port;

    spec.ports=ports;
    spec.params=params;
    spec.widthSpec={1};

end
