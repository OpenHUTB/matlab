function spec=LookupTableNDCharSpec(~)





    spec=struct();









    spec.dataType='fixdt';

    param=characterization.ParamDesc();
    param.name='NumberOfTableDimensions';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'1','2'};
    param.regenerateModel=true;
    params=param;

    param=characterization.ParamDesc();
    param.name='IndexSearchMethod';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'Evenly spaced points'};
    param.doNotOutput=true;
    param.regenerateModel=false;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='InterpMethod';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'Flat'};
    param.doNotOutput=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='ExtrapMethod';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'Clip'};
    param.doNotOutput=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='RndMeth';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'Simplest'};
    param.doNotOutput=true;
    params(end+1)=param;

    param=characterization.ParamDesc();
    param.name='UseOneInputPortForAllInputData';
    param.type=characterization.ParamDesc.SIMULINK_PARAM;
    param.values={'off'};
    param.doNotOutput=true;
    params(end+1)=param;

    port=characterization.PortDesc();
    port.port={characterization.PortDesc.REMAINING_PORTS};
    port.range={2,16,2};
    port.widthTemplate='fixdt(0,%d,0)';
    ports=port;

    spec.ports=ports;
    spec.params=params;
    spec.widthSpec={1};

end
