function spec=RoundingFunctionCharSpec(compName)




    spec=struct();










    spec.dataType='nfpdt';

    switch compName
    case 'nfp_floor_comp'

        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'floor'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;

    case 'nfp_ceil_comp'

        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'ceil'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;

    case 'nfp_round_comp'

        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'round'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;

    case 'nfp_fix_comp'

        param=characterization.ParamDesc();
        param.name='Operator';
        param.type=characterization.ParamDesc.SIMULINK_PARAM;
        param.values={'fix'};
        param.toolDepedentParam=true;
        param.regenerateModel=true;
    end


    param1=characterization.ParamDesc();
    param1.name='LatencyStrategy';
    param1.type=characterization.ParamDesc.HDL_PARAM;
    param1.values={'Custom'};
    param1.doNotOutput=true;
    param1.toolDepedentParam=true;
    param1.regenerateModel=true;

    param2=characterization.ParamDesc();
    param2.name='NFPCustomLatency';
    param2.type=characterization.ParamDesc.HDL_PARAM;
    param2.values={0,1,2,3,4,5};
    param2.doNotOutput=true;
    param2.toolDepedentParam=true;
    param2.regenerateModel=true;

    params=[param,param1,param2];

    inport1=characterization.PortDesc();
    inport1.port={1};
    inport1.range={32,64,32};
    inport1.widthTemplate='';

    ports=inport1;

    spec.params=params;
    spec.ports=ports;
    spec.widthSpec={1};

end
