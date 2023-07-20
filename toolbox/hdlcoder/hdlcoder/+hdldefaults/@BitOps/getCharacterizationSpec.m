function spec=getCharacterizationSpec(~)





    spec=struct();




    param=characterization.ParamDesc();
    param.name='Operator';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'AND'};
    param.doNotOutput=true;
    params=param;

    param=characterization.ParamDesc();
    param.name='UseBitMask';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'off'};
    param.doNotOutput=true;
    param.regenerateModel=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='NumInputPorts';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.regenerateModel=true;
    param.values={'2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','32','64'};
    params(end+1)=param;




    port=characterization.PortDesc();
    port.port=characterization.PortDesc.REMAINING_PORTS;
    port.range={4,4,4};
    port.widthTemplate='fixdt(0, %d, 0)';
    ports=port;

    spec.ports=ports;
    spec.params=params;
    spec.widthSpec={1};

end
